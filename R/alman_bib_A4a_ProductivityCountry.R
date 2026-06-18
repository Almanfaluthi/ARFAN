#' Country Productivity & Collaboration (Robust Version)
#'
#' @description
#' Visualizes top productive countries.
#' - Handles missing/zero citation data gracefully.
#' - Auto-detects 'Cited by' or 'Cited.by' columns.
#' - Skips correlation test if standard deviation is zero.
#'
#' @param data A data frame containing bibliographic data.
#' @param affil_col String. Column name for Affiliations.
#' @param cite_col String. Preferred name for Citations (will auto-search if not found).
#' @param top_n Integer. Number of countries to show.
#' @param scp_col Color for Single Country Publications (Domestic).
#' @param mcp_col Color for Multi Country Publications (International).
#' @param diamond_col Color for Citations.
#'
#' @importFrom dplyr filter mutate group_by summarize n arrange desc rename
#' @importFrom stringr str_trim
#' @importFrom ggplot2 ggplot aes geom_col geom_point geom_line geom_text annotate scale_fill_manual scale_y_continuous sec_axis dup_axis labs theme_minimal theme element_text element_blank
#' @importFrom tidyr unnest pivot_longer
#' @importFrom stats cor.test sd
#' @importFrom utils head tail
#' @export
#' @examples
#' \dontrun{
#' # 1. Basic
#' alman_bib_A4a_ProductivityCountry(df_patientsafety)
#'
#' # 2. Custom colour
#' alman_bib_A4a_ProductivityCountry(
#'   top_n = 5,
#'   data = df_patientsafety,
#'   scp_col = "#D7BDE2",
#'   mcp_col = "#884EA0",
#'   diamond_col = "#D35400"
#' )
#' }
alman_bib_A4a_ProductivityCountry <- function(data,
                                              affil_col = "Affiliations",
                                              cite_col = "Cited by",
                                              top_n = 10,
                                              scp_col = "#AED6F1",
                                              mcp_col = "#2E86C1",
                                              diamond_col = "#C0392B") {

  # ==========================================
  # 1. INTELLIGENT COLUMN DETECTION
  # ==========================================
  if(!affil_col %in% names(data)) stop(paste0("Error: '", affil_col, "' column not found."))

  # Attempt to find the correct Citation column
  possible_cites <- c(cite_col, "Cited.by", "Cited_by", "TC", "Cites", "Times.Cited")
  actual_cite_col <- NULL

  for(col in possible_cites) {
    if(col %in% names(data)) {
      actual_cite_col <- col
      break
    }
  }

  # Prepare Citation Data
  if(!is.null(actual_cite_col)) {
    message(paste("Using citation column:", actual_cite_col))
    data$Target_Cites <- as.numeric(as.character(data[[actual_cite_col]]))
    data$Target_Cites[is.na(data$Target_Cites)] <- 0
  } else {
    warning("Citation column not found. Setting citations to 0.")
    data$Target_Cites <- 0
  }

  # ==========================================
  # 2. DATA PROCESSING (Countries & Collaboration)
  # ==========================================
  df_proc <- data[!is.na(data[[affil_col]]) & data[[affil_col]] != "", , drop = FALSE]
  df_proc[[affil_col]] <- as.character(df_proc[[affil_col]])

  # Extract Unique Countries (Robust Method)
  get_countries <- function(x) {
    if(is.na(x) || x == "") return(NA)
    parts <- unlist(strsplit(x, ";"))
    countries <- sapply(parts, function(p) {
      loc_parts <- unlist(strsplit(p, ","))
      if(length(loc_parts) > 0) return(stringr::str_trim(utils::tail(loc_parts, 1))) else return(NA)
    })

    ctry <- unique(countries[!is.na(countries)])
    # Standardize common names
    ctry <- gsub("United States", "USA", ctry)
    ctry <- gsub("United Kingdom", "UK", ctry)
    ctry <- gsub("England", "UK", ctry)
    ctry <- gsub("Korea", "South Korea", ctry)
    ctry <- gsub("Viet Nam", "Vietnam", ctry)
    ctry <- gsub("Russian Federation", "Russia", ctry)
    ctry <- gsub("\\.", "", ctry)

    return(ctry)
  }

  df_proc$country_list <- lapply(df_proc[[affil_col]], get_countries)

  # SCP vs MCP Logic
  df_proc$collab_type <- sapply(df_proc$country_list, function(x) {
    if(length(x) > 1) return("MCP") else return("SCP")
  })

  # Unnest and Aggregate
  df_long <- df_proc %>%
    tidyr::unnest(country_list) %>%
    dplyr::rename(Country = country_list)

  # Fix slice_max issue by using head() with order for base compatibility
  country_stats_full <- df_long %>%
    dplyr::group_by(Country) %>%
    dplyr::summarize(
      Total_Docs = dplyr::n(),
      n_SCP = sum(collab_type == "SCP"),
      n_MCP = sum(collab_type == "MCP"),
      Total_Citations = sum(Target_Cites, na.rm = TRUE)
    ) %>%
    dplyr::filter(Country != "" & !is.na(Country)) %>%
    dplyr::arrange(dplyr::desc(Total_Docs))

  country_stats <- utils::head(country_stats_full, top_n)

  # ==========================================
  # 3. SAFE STATISTICAL ANALYSIS
  # ==========================================

  # Check if we have valid citation data for correlation
  has_citations <- sum(country_stats$Total_Citations) > 0
  has_variance  <- stats::sd(country_stats$Total_Docs) > 0 && stats::sd(country_stats$Total_Citations) > 0

  if(has_citations && has_variance) {
    cor_res <- stats::cor.test(country_stats$Total_Docs, country_stats$Total_Citations)
    cor_val <- round(cor_res$estimate, 2)
    cor_p   <- format.pval(cor_res$p.value, digits=3)
    cor_text <- paste0("Vol-Impact Corr: r=", cor_val, " (p=", cor_p, ")")
  } else {
    cor_text <- "Vol-Impact Corr: N/A (Low/Zero Variance)"
  }

  avg_mcp <- mean(country_stats$n_MCP / country_stats$Total_Docs, na.rm=TRUE) * 100

  stats_label <- paste0(
    "Statistical Insights\n", cor_text, "\n", "Avg Intl. Collaboration: ", round(avg_mcp, 1), "%")

  # ==========================================
  # 4. DUAL AXIS SCALING LOGIC
  # ==========================================
  max_doc <- max(country_stats$Total_Docs)
  max_cit <- max(country_stats$Total_Citations)

  # If citations are 0, we simply disable the secondary scaling to avoid errors
  if(max_cit > 0) {
    scale_factor <- max_doc / max_cit * 0.8
    sec_axis_def <- ggplot2::sec_axis(~ . / scale_factor, name = "Total Citations")
  } else {
    scale_factor <- 1
    sec_axis_def <- ggplot2::dup_axis(name = "") # Empty axis if no citations
  }

  # Prepare Plot Data
  plot_data <- country_stats %>%
    tidyr::pivot_longer(cols = c("n_SCP", "n_MCP"), names_to = "Type", values_to = "Count")

  plot_data$Country <- factor(plot_data$Country, levels = country_stats$Country)

  footer_text <- paste0("Generated by R-Studio (", R.version.string, ") on ",
                        format(Sys.time(), "%B %d, %Y at %H:%M:%S"))
  

  # ==========================================
  # 5. GENERATE PLOT
  # ==========================================
  p <- ggplot2::ggplot() +

    # Bars
    ggplot2::geom_col(data = plot_data, ggplot2::aes(x = Country, y = Count, fill = Type),
                      width = 0.7, alpha = 0.9) +

    # Stats Box
    ggplot2::annotate("label", x = Inf, y = Inf, label = stats_label,
                      hjust = 1.05, vjust = 1.05, size = 3,
                      fill = "white", alpha = 0.8, family = "mono") +

    ggplot2::scale_fill_manual(values = c("n_MCP" = mcp_col, "n_SCP" = scp_col),
                               labels = c("Multiple Country (Intl)", "Single Country (Domestic)")) +

    ggplot2::scale_y_continuous(name = "Number of Publications", sec.axis = sec_axis_def) +

    ggplot2::labs(title = paste("Top", top_n, "Most Productive Countries & Impact"),
                  subtitle = if(has_citations) "Bars: Productivity | Diamonds: Citation Impact" else "Bars: Productivity (No Citation Data Available)",
                  caption = footer_text,
                  fill = "Collaboration Type") +

    ggplot2::theme_minimal() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", size = 14),
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1, face = "bold"),
      axis.title.y.right = ggplot2::element_text(color = if(has_citations) diamond_col else "transparent", face = "bold"),
      legend.position = "top",
      panel.grid.major.x = ggplot2::element_blank()
    )

  # Diamond Points, Connector Line and Labels (Only if we have citations)
  if(has_citations) {
     p <- p +
       ggplot2::geom_point(data = country_stats,
                           ggplot2::aes(x = Country, y = Total_Citations * scale_factor, group = 1),
                           shape = 18, size = 5, color = diamond_col) +
       ggplot2::geom_line(data = country_stats,
                          ggplot2::aes(x = Country, y = Total_Citations * scale_factor, group = 1),
                          color = diamond_col, linetype = "dotted", alpha = 0.5) +
       ggplot2::geom_text(data = country_stats,
                          ggplot2::aes(x = Country, y = Total_Citations * scale_factor, label = Total_Citations),
                          vjust = -1.2, size = 3, fontface = "bold", color = diamond_col)
  }

  return(p)
}
