#' Executive Summary Dashboard (Infographic Style)
#'
#' @description
#' A comprehensive "One-Page" dashboard that summarizes the entire dataset.
#' It calculates CAGR, Collaboration Rates, and H-Indices, and presents them
#' in a modern, grid-based infographic layout.
#'
#' @param data A data frame containing bibliographic data.
#' @param year_col String. Year column (default: "Year").
#' @param author_col String. Author column (default: "Authors").
#' @param cite_col String. Citation column (default: "Cited by").
#' @param affil_col String. Affiliation column (default: "Affiliations").
#' @param primary_col Color for main elements (default: "maroon").
#' @param accent_col Color for highlights (default: "red").
#' @param exclude_terms Vector of strings. Specific authors or countries to remove from the top 3 analysis (e.g., c("Sweden")).
#'
#' @importFrom dplyr summarize mutate group_by arrange top_n n_distinct filter select slice desc n %>%
#' @importFrom ggplot2 ggplot aes geom_tile geom_text geom_line geom_area geom_point geom_col coord_flip theme_void theme_minimal labs theme element_text element_rect element_blank margin expansion annotate xlim ylim scale_y_continuous
#' @importFrom patchwork wrap_plots plot_layout plot_annotation
#' @importFrom stringr str_trim
#' @importFrom rlang sym !!
#' @importFrom tidyr separate_rows
#' @importFrom utils head tail
#' @importFrom stats reorder
#' @export
#' @examples
#' \dontrun{
#' # 1. Standard (Maroon/Red look)
#' alman_bib_A0_ExecutiveSummary(df_patientsafety)
#'
#' # 2. Standard with Exclusion (Custom color)
#' alman_bib_A0_ExecutiveSummary(df_herbal_leptospirosis, primary_col = "#2c3e50", accent_col = "#e74c3c")
#'
#' # 3. Standard with other colour
#' alman_bib_A0_ExecutiveSummary(df_herbal_snakebite, primary_col = "red", accent_col = "blue")
#'}

alman_bib_A0_ExecutiveSummary <- function(data,
                                          year_col = "Year",
                                          author_col = "Authors",
                                          cite_col = "Cited by",
                                          affil_col = "Affiliations",
                                          primary_col = "maroon",
                                          accent_col = "red",
                                          exclude_terms = NULL) {

  # ==========================================
  # 1. SMART COLUMN DETECTION (The Fix)
  # ==========================================
  # Find the actual Citation column name (handles "Cited.by" vs "Cited by")
  possible_cites <- c(cite_col, "Cited.by", "Cited_by", "TC", "Cites", "Total.Citations")
  actual_cite_col <- NULL
  for(col in possible_cites) {
    if(col %in% names(data)) {
      actual_cite_col <- col
      break
    }
  }

  # If still not found, warn user but don't crash
  if(is.null(actual_cite_col)) {
    warning("Could not find Citation column. Citations will be 0.")
    data$Target_Cites <- 0
  } else {
    data$Target_Cites <- as.numeric(as.character(data[[actual_cite_col]]))
    data$Target_Cites[is.na(data$Target_Cites)] <- 0
  }

  # Ensure other columns exist
  data[[year_col]] <- as.numeric(as.character(data[[year_col]]))
  data[[author_col]] <- as.character(data[[author_col]])
  data[[affil_col]] <- as.character(data[[affil_col]])

  # Normalize exclude_terms to lowercase for case-insensitive filtering
  if(!is.null(exclude_terms)) {
    exclude_terms <- tolower(exclude_terms)
  } else {
    exclude_terms <- character(0)
  }

  # ==========================================
  # 2. CALCULATE KPI METRICS (The 5 Boxes)
  # ==========================================

  # (1) Total Documents
  total_docs <- nrow(data)

  # (2) Total Authors
  all_authors <- unlist(strsplit(data[[author_col]], ";"))
  total_authors <- length(unique(str_trim(all_authors)))

  # (3) International Collaboration %
  count_countries <- function(affil_str) {
    if(is.na(affil_str) || nchar(trimws(affil_str)) == 0) return(0)
    parts <- unlist(strsplit(affil_str, ";"))
    countries <- c()
    for(a in parts) {
      locs <- unlist(strsplit(a, ","))
      if(length(locs) > 0) countries <- c(countries, str_trim(tail(locs, 1)))
    }
    return(length(unique(countries[countries != ""])))
  }
  data$n_countries <- sapply(data[[affil_col]], count_countries)
  int_collab_rate <- round((sum(data$n_countries > 1, na.rm=TRUE) / total_docs) * 100, 1)

  # (4) Document Average Year
  years <- data[[year_col]]
  years <- years[!is.na(years) & years > 1900 & years < 2030]
  avg_year <- round(mean(years, na.rm=TRUE))

  # (5) Growth Rate (CAGR)
  year_counts <- table(years)
  if(length(year_counts) > 1) {
    start_n <- as.numeric(head(year_counts, 1))
    end_n <- as.numeric(tail(year_counts, 1))
    n_years <- length(year_counts)
    cagr <- round(((end_n / start_n)^(1/n_years) - 1) * 100, 2)
    if(is.infinite(cagr) || is.nan(cagr)) cagr <- 0
  } else { cagr <- 0 }

  # ==========================================
  # 3. GENERATE KPI CARDS
  # ==========================================
  create_card <- function(title, value, subtext, color) {
    ggplot() +
      annotate("text", x = 0.5, y = 0.65, label = value, size = 8, fontface = "bold", color = color) +
      annotate("text", x = 0.5, y = 0.35, label = title, size = 3, fontface = "bold", color = "gray40") +
      annotate("text", x = 0.5, y = 0.2, label = subtext, size = 2.5, fontface = "italic", color = "gray60") +
      xlim(0, 1) + ylim(0, 1) +
      theme_void() +
      theme(panel.background = element_rect(fill = "white", color = "gray90", linewidth = 1))
  }

  card1 <- create_card("DOCUMENTS", total_docs, "Total Volume", primary_col)
  card2 <- create_card("AUTHORS", total_authors, "Unique Contributors", primary_col)
  card3 <- create_card("INT'L COLLAB", paste0(int_collab_rate, "%"), "Multi-country Docs", accent_col)
  card4 <- create_card("AVG PUB YEAR", avg_year, "Mean Vintage", primary_col)
  card5 <- create_card("GROWTH RATE", paste0(cagr, "%"), "Annual (CAGR)", accent_col)

  # ==========================================
  # 4. MIDDLE: PRODUCTION TREND
  # ==========================================
  df_trend <- as.data.frame(table(years))
  colnames(df_trend) <- c("Year", "Freq")
  df_trend$Year <- as.numeric(as.character(df_trend$Year))

  p_trend <- ggplot(df_trend, aes(x = Year, y = Freq)) +
    geom_area(fill = primary_col, alpha = 0.1) +
    geom_line(color = primary_col, linewidth = 1) +
    geom_point(data = tail(df_trend, 1), color = accent_col, size = 2) +
    labs(title = "Production Trend", subtitle = paste0("Timeline: ", min(years), " - ", max(years))) +
    theme_minimal() +
    theme(axis.title = element_blank(), panel.grid = element_blank())

  # ==========================================
  # 5. BOTTOM LEFT: TOP 3 AUTHORS
  # ==========================================
  df_auth_exp <- data %>%
    select(Item = !!rlang::sym(author_col), Cites = Target_Cites) %>%
    filter(!is.na(Item)) %>%
    tidyr::separate_rows(Item, sep = ";") %>%
    mutate(Item = str_trim(Item)) %>%
    filter(Item != "") %>%
    filter(!(tolower(Item) %in% exclude_terms)) %>% # <-- NEW EXCLUSION FILTER
    group_by(Item) %>%
    summarize(Pubs = n(), Total_Cites = sum(Cites, na.rm=TRUE)) %>%
    top_n(3, wt = Pubs) %>%
    arrange(desc(Pubs)) %>%
    slice(1:3)

  p_auth <- ggplot(df_auth_exp, aes(x = reorder(Item, Pubs), y = Pubs)) +
    geom_col(fill = primary_col, width = 0.5) +
    geom_point(aes(y = Pubs + (max(Pubs)*0.1), size = Total_Cites), color = accent_col, show.legend = FALSE) +
    geom_text(aes(label = Pubs), y = 0.2, color = "white", size = 3, fontface = "bold", hjust=0) +
    geom_text(aes(y = Pubs + (max(Pubs)*0.15), label = paste0(Total_Cites, " Cit.")),
              size = 3, color = accent_col, fontface = "italic", hjust=0) +
    scale_y_continuous(expand = expansion(mult = c(0, 0.4))) +
    coord_flip() +
    labs(title = "Top 3 Authors", subtitle = "Bars: Pubs | Dots: Citations") +
    theme_void() +
    theme(axis.text.y = element_text(hjust = 1, color = "black", face="bold", margin=margin(r=5)),
          plot.title = element_text(size = 11, face = "bold"),
          plot.margin = margin(10, 10, 10, 10))

  # ==========================================
  # 6. BOTTOM RIGHT: TOP 3 COUNTRIES
  # ==========================================
  extract_country_safe <- function(x) {
    if(is.na(x) || nchar(trimws(x)) == 0) return(NA)
    parts <- unlist(strsplit(x, ";"))[1]
    locs <- unlist(strsplit(parts, ","))
    if(length(locs) > 0) return(str_trim(tail(locs, 1))) else return(NA)
  }

  df_country_exp <- data %>%
    mutate(Country = sapply(!!rlang::sym(affil_col), extract_country_safe)) %>%
    filter(!is.na(Country)) %>%
    mutate(Country = gsub("United States", "USA", Country),
           Country = gsub("United Kingdom", "UK", Country),
           Country = gsub("Indonesia", "IDN", Country)) %>%
    filter(!(tolower(Country) %in% exclude_terms)) %>% # <-- NEW EXCLUSION FILTER
    group_by(Country) %>%
    summarize(Pubs = n(), Total_Cites = sum(Target_Cites, na.rm=TRUE)) %>%
    top_n(3, wt = Pubs) %>%
    arrange(desc(Pubs)) %>%
    slice(1:3)

  p_country <- ggplot(df_country_exp, aes(x = reorder(Country, Pubs), y = Pubs)) +
    geom_col(fill = "gray70", width = 0.5) +
    geom_point(aes(y = Pubs + (max(Pubs)*0.1), size = Total_Cites), color = primary_col, show.legend = FALSE) +
    geom_text(aes(label = Pubs), y = 0.2, color = "white", size = 3, fontface = "bold", hjust=0) +
    geom_text(aes(y = Pubs + (max(Pubs)*0.15), label = paste0(Total_Cites, " Cit.")),
              size = 3, color = primary_col, fontface = "italic", hjust=0) +
    scale_y_continuous(expand = expansion(mult = c(0, 0.4))) +
    coord_flip() +
    labs(title = "Top 3 Countries", subtitle = "Bars: Pubs | Dots: Citations") +
    theme_void() +
    theme(axis.text.y = element_text(hjust = 1, color = "black", face="bold", margin=margin(r=5)),
          plot.title = element_text(size = 11, face = "bold"),
          plot.margin = margin(10, 10, 10, 10))

  # ==========================================
  # 7. ASSEMBLE
  # ==========================================

  layout <- (card1 | card2 | card3 | card4 | card5) /
    (p_trend) /
    (p_auth | p_country) +
    plot_layout(heights = c(0.8, 1.2, 1.5)) +
    plot_annotation(
      title = "Bibliometric Executive Summary",
      subtitle = "Strategic Performance & Leadership Overview",
      caption = paste0("Generated by R-Studio (", R.version.string, ") on ",
                       format(Sys.time(), "%B %d, %Y at %H:%M:%S")),
      theme = theme(
        plot.title = element_text(size = 16, face = "bold", color = primary_col),
        plot.subtitle = element_text(size = 10, color = "gray50")
      )
    )

  return(layout)
}
