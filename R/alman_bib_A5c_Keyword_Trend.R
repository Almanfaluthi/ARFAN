#' Trend Timeline Analysis (Interquartile Range Plot)
#'
#' @description
#' A sophisticated "Timeline" visualization that tracks the active lifespan of keywords.
#' Instead of a simple point, it visualizes the "Middle 50%" (Q1 to Q3) of the topic's activity.
#' Features:
#' 1. Automates Q1/Median/Q3 calculation from raw data.
#' 2. Sorts topics by Recency (Newest on top).
#' 3. Visualizes Frequency (Bubble Size) and Recency (Color).
#' 4. Year axis and legend strictly formatted as whole integers.
#'
#' @param data A data frame containing bibliographic data.
#' @param keyword_col String. Column name for keywords (default: "Author.Keywords").
#' @param year_col String. Column name for Year (default: "Year").
#' @param top_n Integer. Number of top keywords to analyze (default: 10).
#' @param remove_words Vector. Junk words to remove.
#' @param low_col Color for older trends (default: "#3498db" - Blue).
#' @param high_col Color for newer trends (default: "#e74c3c" - Red).
#'
#' @importFrom stats quantile median
#' @importFrom stringr str_trim str_to_lower str_to_title
#' @importFrom dplyr select filter mutate group_by summarize arrange desc n pull
#' @importFrom ggplot2 ggplot aes geom_segment geom_point scale_color_gradient scale_size_continuous scale_x_continuous labs theme_minimal annotate theme element_text element_blank margin
#' @importFrom tidyr separate_rows
#' @importFrom rlang sym !!
#' @importFrom utils head
#' @export
#' @examples
#' \dontrun{
#' # Standard
#' alman_bib_A5c_Keyword_Trend(df_patientsafety)
#'
#' # "Sunset" Theme (Purple to Orange)
#' alman_bib_A5c_Keyword_Trend(df_patientsafety, low_col = "#8e44ad", high_col = "#d35400")
#'
#' # Remove unrelevant - Define the junk words you hate
#' junk_list <- c("article", "human", "priority journal", "female", "male", "adult")
#' alman_bib_A5c_Keyword_Trend(df_patientsafety, remove_words = junk_list)
#' }
alman_bib_A5c_Keyword_Trend <- function(data,
                                        keyword_col = "Author.Keywords",
                                        year_col = "Year",
                                        top_n = 10,
                                        remove_words = NULL,
                                        low_col = "#3498db",
                                        high_col = "#e74c3c") {

  # ==========================================
  # 1. DATA PREPARATION & CALCULATION
  # ==========================================
  if(!keyword_col %in% names(data)) stop(paste0("Error: '", keyword_col, "' column not found."))
  if(!year_col %in% names(data)) stop(paste0("Error: '", year_col, "' column not found."))

  sym_year <- rlang::sym(year_col)
  sym_keyword <- rlang::sym(keyword_col)

  # Clean, Unnest, and Filter safely
  df_clean <- data %>%
    dplyr::select(Year = !!sym_year, Keyword = !!sym_keyword) %>%
    dplyr::filter(!is.na(Year) & !is.na(Keyword)) %>%
    tidyr::separate_rows(Keyword, sep = ";") %>%
    dplyr::mutate(
      Keyword = stringr::str_trim(stringr::str_to_lower(Keyword)),
      Year = as.numeric(as.character(Year))
    ) %>%
    dplyr::filter(Keyword != "" & Year > 1900 & Year < 2030)

  # --- REMOVE UNWANTED WORDS ---
  if(!is.null(remove_words)) {
    # Convert blacklist to lowercase to match data
    blacklist <- stringr::str_to_lower(remove_words)
    df_clean <- df_clean %>%
      dplyr::filter(!Keyword %in% blacklist)
  }

  if(nrow(df_clean) == 0) stop("No valid data remaining after filtering.")

  # 1. Identify Top N Keywords by Frequency (Using head for safety)
  top_keywords_df <- df_clean %>%
    dplyr::group_by(Keyword) %>%
    dplyr::summarize(Freq = dplyr::n()) %>%
    dplyr::arrange(dplyr::desc(Freq))

  top_keywords <- utils::head(top_keywords_df, top_n) %>%
    dplyr::pull(Keyword)

  # 2. Calculate Q1, Median, Q3 for these keywords
  df_stats <- df_clean %>%
    dplyr::filter(Keyword %in% top_keywords) %>%
    dplyr::group_by(Keyword) %>%
    dplyr::summarize(
      Freq = dplyr::n(),
      Year_Min = min(Year, na.rm = TRUE),
      Year_Q1 = stats::quantile(Year, 0.25, na.rm = TRUE),
      Year_Med = stats::median(Year, na.rm = TRUE),
      Year_Q3 = stats::quantile(Year, 0.75, na.rm = TRUE),
      Year_Max = max(Year, na.rm = TRUE),
      Duration = Year_Q3 - Year_Q1
    ) %>%
    dplyr::arrange(dplyr::desc(Year_Med)) # Sort by Newest Median

  # Reorder Factor for Plotting (Newest at Top)
  df_stats$Keyword <- factor(df_stats$Keyword, levels = df_stats$Keyword[order(df_stats$Year_Med)])

  # ==========================================
  # 2. STATISTICAL INSIGHTS
  # ==========================================
  newest_topic <- as.character(df_stats$Keyword[which.max(df_stats$Year_Med)])
  longest_sustained <- as.character(df_stats$Keyword[which.max(df_stats$Duration)])

  stats_label <- paste0(
    "Timeline Insights:\n",
    "1. Newest Trend: '", stringr::str_to_title(newest_topic), "'\n",
    "2. Most Sustained: '", stringr::str_to_title(longest_sustained), "'\n",
    "3. Range: Interquartile (Middle 50% activity)"
  )

  # ==========================================
  # 3. VISUALIZATION
  # ==========================================
  footer_text <- paste0("Generated by R-Studio (", R.version.string, ") on ",
                        format(Sys.time(), "%B %d, %Y at %H:%M:%S"))

  p <- ggplot2::ggplot(df_stats, ggplot2::aes(y = Keyword)) +

    # 1. The Timeline Range (Q1 to Q3)
    ggplot2::geom_segment(ggplot2::aes(x = Year_Q1, xend = Year_Q3, yend = Keyword),
                          color = "gray70", linewidth = 1.5, alpha = 0.5) +

    # 2. Thin line extending to Min/Max
    ggplot2::geom_segment(ggplot2::aes(x = Year_Min, xend = Year_Max, yend = Keyword),
                          color = "gray90", linewidth = 0.5, linetype = "dotted") +

    # 3. The Median Point
    ggplot2::geom_point(ggplot2::aes(x = Year_Med, size = Freq, color = Year_Med),
                        alpha = 0.9) +

    # 4. Borderless Stats Annotation
    ggplot2::annotate("text", x = min(df_stats$Year_Min), y = top_n, label = stats_label,
                      hjust = 0, vjust = 1, size = 3, fontface = "italic", color = "#2c3e50") +

    # 5. Scales (X-Axis and Color Legend strictly integers)
    ggplot2::scale_x_continuous(breaks = function(x) unique(as.integer(pretty(x)))) +

    # NEW FIX: Applied the same integer-forcing breaks to the color legend!
    ggplot2::scale_color_gradient(
      low = low_col, high = high_col,
      name = "Median Year (Recency)",
      breaks = function(x) unique(as.integer(pretty(x)))
    ) +

    ggplot2::scale_size_continuous(range = c(4, 10), name = "Frequency") +

    # 6. Labels & Theme
    ggplot2::labs(title = "Topic Lifespan & Recency",
                  subtitle = paste0("Timeline of Top ", top_n, " Terms (Showing Q1 - Median - Q3)"),
                  x = "Year",
                  y = "",
                  caption = footer_text) +

    ggplot2::theme_minimal() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", size = 14),
      plot.subtitle = ggplot2::element_text(face = "italic", size = 10, color = "gray50"),
      axis.text.y = ggplot2::element_text(face = "bold", size = 10, color = "#2c3e50"),
      panel.grid.major.y = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      legend.position = "right",
      plot.caption = ggplot2::element_text(color = "gray60", size = 8, margin = ggplot2::margin(t = 20))
    )

  return(p)
}
