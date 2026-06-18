#' Author Impact & Productivity Analysis (Lotka & Fractionalized)
#'
#' @description
#' This function analyzes author productivity. It calculates:
#' 1. Fractionalized Credit (1/N authors per paper).
#' 2. Lotka's Law Coefficient (Beta) to test scientific productivity distribution.
#' 3. Visualizes the Top N authors, comparing Total Output vs. Fractional Contribution.
#'
#' @param data A data frame containing the bibliographic data.
#' @param author_col String. Column name for Authors (default: "Authors").
#' @param cite_col String. Column name for Citations (default: "Cited by").
#' @param top_n Integer. How many top authors to visualize (default: 10).
#' @param main_col Color for Fractionalized count (default: "#2c3e50").
#' @param ghost_col Color for Total count background (default: "#bdc3c7").
#'
#' @importFrom stringr str_count
#' @importFrom ggplot2 ggplot aes geom_col geom_text labs theme_minimal theme coord_flip
#' @importFrom stats lm
#' @importFrom rlang := sym
#' @export
#' @examples
#' \dontrun{
#' # Standard Usage (Top 10 authors)
#' alman_bib_A2a_AuthorsAnalysis(df_patientsafety)
#'
#' # Customize Colors (e.g., Blue and Light Blue)
#' alman_bib_A2a_AuthorsAnalysis(df_herbal_leptospirosis, top_n = 15,
#'   main_col = "#2980b9", ghost_col = "#d6eaf8")
#' }

alman_bib_A2a_AuthorsAnalysis <- function(data,
                                       author_col = "Authors",
                                       cite_col = "Cited by",
                                       top_n = 10,
                                       main_col = "#27ae60",
                                       ghost_col = "#d6eaf8") {

  # ==========================================
  # 1. DATA PREPARATION & FRACTIONALIZATION
  # ==========================================
  if(!author_col %in% names(data)) stop(paste0("Error: '", author_col, "' column not found."))

  # Clean Data
  df_clean <- data[!is.na(data[[author_col]]), ]

  # Ensure citations are numeric
  if(cite_col %in% names(df_clean)) {
    df_clean[[cite_col]] <- as.numeric(as.character(df_clean[[cite_col]]))
    df_clean[[cite_col]][is.na(df_clean[[cite_col]])] <- 0
  } else {
    df_clean$Cites <- 0 # Placeholder if no citation column
    cite_col <- "Cites"
  }

  # A. Calculate Authors per Paper (N)
  # Scopus separates authors with ";". We count semicolons + 1.
  df_clean$n_authors <- stringr::str_count(df_clean[[author_col]], ";") + 1
  df_clean$frac_score <- 1 / df_clean$n_authors

  # B. Split Authors (Unnesting)
  # We need to separate rows to get individual author stats
  # Note: This might take a moment for large datasets
  df_long <- df_clean %>%
    dplyr::mutate(temp_id = 1:nrow(.)) %>% # Create temp ID to track papers
    tidyr::separate_rows(!!rlang::sym(author_col), sep = ";") %>%
    dplyr::mutate(!!rlang::sym(author_col) := trimws(!!rlang::sym(author_col)))

  # Filter out empty authors or "et al"
  df_long <- df_long[df_long[[author_col]] != "" & !is.na(df_long[[author_col]]), ]

  # C. Aggregate Stats per Author
  author_stats <- df_long %>%
    dplyr::group_by(!!rlang::sym(author_col)) %>%
    dplyr::summarize(
      Total_Articles = dplyr::n(),
      Fractional_Articles = sum(frac_score),
      Total_Citations = sum(!!rlang::sym(cite_col), na.rm = TRUE)
    ) %>%
    dplyr::arrange(desc(Fractional_Articles))

  # ==========================================
  # 2. LOTKA'S LAW CALCULATION (Productivity)
  # ==========================================
  # Lotka's Law: Frequency of authors publishing n papers ~ 1/n^2
  # We run a log-log regression to find the Beta coefficient.

  lotka_data <- as.data.frame(table(author_stats$Total_Articles))
  colnames(lotka_data) <- c("Papers_n", "Authors_count")
  lotka_data$Papers_n <- as.numeric(as.character(lotka_data$Papers_n))

  # Linear Regression on Log-Log scale
  # Log(Authors) = C - Beta * Log(Papers)
  # Filtering out extreme tails for better fit usually helps, but we keep all for raw result
  model_lotka <- stats::lm(log(Authors_count) ~ log(Papers_n), data = lotka_data)

  beta_coeff <- abs(coef(model_lotka)[2]) # The slope is negative, we take abs
  r_squared  <- summary(model_lotka)$r.squared

  pct_single_paper <- (lotka_data$Authors_count[lotka_data$Papers_n == 1] / sum(lotka_data$Authors_count)) * 100
  if(length(pct_single_paper) == 0) pct_single_paper <- 0

  # Stats Text
  lotka_status <- ifelse(beta_coeff > 1.8 & beta_coeff < 2.5, "Fits Standard Lotka (~2.0)", "Deviates from Lotka")

  stats_label <- paste0(
    "Productivity Analysis:", "\n",
    " Authors analyzed: ", nrow(author_stats), "\n",
    " % One-Paper Authors: ", "\n", round(pct_single_paper, 1), "%", "\n",
    "-------------------------", "\n",
    "Lotka's Law (Beta): ", round(beta_coeff, 2), "\n",
    " Model Fit (Rsquare): ", round(r_squared, 3), "\n",
    " Interpretation: ", "\n", lotka_status
  )

  # ==========================================
  # 3. VISUALIZATION (Top N Authors)
  # ==========================================
  plot_data <- head(author_stats, top_n)

  # Reorder factor for plotting
  plot_data[[author_col]] <- factor(plot_data[[author_col]],
                                    levels = plot_data[[author_col]][order(plot_data$Fractional_Articles)])

  footer_text <- paste0("Generated by R-Studio (", R.version.string, ") on ",
                        format(Sys.time(), "%B %d, %Y at %H:%M:%S"))

  p <- ggplot2::ggplot(plot_data) +

    # 1. Ghost Bars (Total Articles) - Shows "Team Size" context
    ggplot2::geom_col(aes(x = !!rlang::sym(author_col), y = Total_Articles),
                      fill = ghost_col, width = 0.6) +

    # 2. Main Bars (Fractionalized) - Shows "Real Contribution"
    ggplot2::geom_col(aes(x = !!rlang::sym(author_col), y = Fractional_Articles),
                      fill = main_col, width = 0.4) +

    # 3. Text Labels (End of bars)
    ggplot2::geom_text(aes(x = !!rlang::sym(author_col), y = Total_Articles,
                           label = paste0("T:", Total_Articles, " | F:", round(Fractional_Articles, 1))),
                       hjust = -0.1, size = 3, color = "gray30") +

    # 4. Stats Text (Clean, no box)
    ggplot2::annotate("text", x = 1, y = max(plot_data$Total_Articles) * 0.8,
                      label = stats_label,
                      hjust = 0, vjust = 0, size = 3, family = "mono", color = "black") +

    # 5. Theme & Labs
    ggplot2::coord_flip() +
    ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0, 0.2))) + # Add space for labels

    ggplot2::labs(title = paste("Top", top_n, "Most Productive Authors"),
                  subtitle = "Comparing Total Publications (Grey) vs. Fractionalized Contribution (Darker)",
                  x = "", y = "Number of Articles",
                  caption = footer_text) +

    ggplot2::theme_minimal() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", size = 14),
      plot.subtitle = ggplot2::element_text(face = "italic", size = 10, color = "gray40"),
      panel.grid.major.y = ggplot2::element_blank(),
      axis.text.y = ggplot2::element_text(face = "bold", size = 10),
      plot.caption = ggplot2::element_text(color = "gray60", size = 8, margin = ggplot2::margin(t = 10))
    )

  return(p)
}
