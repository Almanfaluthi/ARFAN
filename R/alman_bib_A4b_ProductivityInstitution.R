#' Institution Strategic Performance Matrix (Quadrant Analysis)
#'
#' @description
#' A sophisticated analysis that maps institutions based on their
#' Quantity (Total Papers) vs. Quality (Citations per Paper).
#' Features:
#' 1. Strategic Quadrant Analysis.
#' 2. Smart Name Cleaning (removes "Dept", "Faculty", etc.).
#' 3. Full Color Customization via Palettes.
#'
#' @param data A data frame containing bibliographic data.
#' @param affil_col String. Column name for Affiliations.
#' @param cite_col String. Column name for Citations.
#' @param top_n Integer. How many top institutions to analyze (default: 20).
#' @param min_citations Integer. Filter out institutions with < N citations (default: 5).
#' @param palette String. A continuous color palette name for the numerical mapping (default: "viridis"). Options include "magma", "plasma", "inferno", "cividis", "mako", "rocket", "turbo".
#'
#' @importFrom dplyr filter mutate group_by summarize n arrange desc
#' @importFrom stringr str_remove_all str_trim
#' @importFrom ggplot2 ggplot aes geom_point geom_hline geom_vline annotate scale_color_viridis_c scale_size_continuous labs theme_minimal theme element_text element_blank
#' @importFrom ggrepel geom_text_repel
#' @importFrom tidyr separate_rows
#' @importFrom rlang sym !!
#' @importFrom utils head tail
#' @importFrom stats median
#' @export
#' @examples
#' \dontrun{
#' # Default (Viridis Palette - Green/Blue/Yellow)
#' alman_bib_A4b_ProductivityInstitution(df_herbal_tb)
#'
#' # Magma Palette (Black/Purple/Orange/Yellow)
#' alman_bib_A4b_ProductivityInstitution(df_herbal_tb, top_n = 15, palette = "magma")
#'
#' # Plasma Palette
#' alman_bib_A4b_ProductivityInstitution(df_herbal_tb, top_n = 20, palette = "plasma")
#' }
alman_bib_A4b_ProductivityInstitution <- function(data,
                                                  affil_col = "Affiliations",
                                                  cite_col = "Cited by",
                                                  top_n = 10,
                                                  min_citations = 5,
                                                  palette = "viridis") {

  # ==========================================
  # 1. SMART DATA EXTRACTION & CLEANING
  # ==========================================
  if(!affil_col %in% names(data)) stop(paste0("Error: '", affil_col, "' column not found."))

  # Robust Citation Column Check
  possible_cites <- c(cite_col, "Cited.by", "Cited_by", "TC", "Cites", "Times.Cited")
  actual_cite_col <- NULL
  for(col in possible_cites) { if(col %in% names(data)) { actual_cite_col <- col; break } }

  if(is.null(actual_cite_col)) {
    data$Target_Cites <- 0
    warning("Citation column not found. Impact metrics will be 0.")
  } else {
    data$Target_Cites <- as.numeric(as.character(data[[actual_cite_col]]))
    data$Target_Cites[is.na(data$Target_Cites)] <- 0
  }

  # Filter and separate rows safely for R CMD Check
  df_clean <- data[!is.na(data[[affil_col]]) & data[[affil_col]] != "", , drop = FALSE]
  sym_affil <- rlang::sym(affil_col)

  df_clean <- tidyr::separate_rows(df_clean, !!sym_affil, sep = ";")

  # Base text cleaning without deep piping to avoid R CMD Check notes
  df_clean$Raw_Org <- df_clean[[affil_col]]
  df_clean$Clean_Org <- stringr::str_remove_all(df_clean$Raw_Org, "(?i)Department of [^,]+,")
  df_clean$Clean_Org <- stringr::str_remove_all(df_clean$Clean_Org, "(?i)Faculty of [^,]+,")
  df_clean$Clean_Org <- stringr::str_remove_all(df_clean$Clean_Org, "(?i)School of [^,]+,")
  df_clean$Clean_Org <- stringr::str_remove_all(df_clean$Clean_Org, "(?i)Division of [^,]+,")
  df_clean$Clean_Org <- stringr::str_trim(df_clean$Clean_Org)

  # Further clean: Split by comma and heuristic match
  clean_institution <- function(x) {
    if (is.na(x)) return(NA)
    parts <- unlist(strsplit(x, ","))
    if(length(parts) == 0) return(NA)
    kw <- c("Universi", "Hospit", "Institu", "College", "School", "Ministry", "Center", "Centre")
    match_idx <- grep(paste(kw, collapse="|"), parts, ignore.case=TRUE)

    if(length(match_idx) > 0) {
      return(stringr::str_trim(parts[match_idx[1]]))
    } else {
      return(stringr::str_trim(parts[1]))
    }
  }

  df_clean$Final_Org <- sapply(df_clean$Clean_Org, clean_institution)

  # ==========================================
  # 2. METRIC CALCULATION
  # ==========================================
  org_stats_full <- df_clean %>%
    dplyr::filter(!is.na(Final_Org) & Final_Org != "") %>%
    dplyr::group_by(Final_Org) %>%
    dplyr::summarize(
      Total_Docs = dplyr::n(),
      Total_Cites = sum(Target_Cites, na.rm=TRUE)
    ) %>%
    dplyr::mutate(CPP = round(Total_Cites / Total_Docs, 2)) %>%
    dplyr::filter(Total_Cites >= min_citations) %>%
    dplyr::arrange(dplyr::desc(Total_Docs))

  # Slice max alternative using head() to avoid base generic dispatch warnings
  org_stats <- utils::head(org_stats_full, top_n)

  # Guard against empty stats (if filtering removed everything)
  if(nrow(org_stats) == 0) stop("No institutions found after applying citation minimums.")

  # Calculate Median Thresholds based on the visible top institutions
  med_docs <- stats::median(org_stats$Total_Docs)
  med_cpp  <- stats::median(org_stats$CPP)

  # ==========================================
  # 3. VISUALIZATION (Strategic Matrix)
  # ==========================================
  footer_text <- paste0("Generated by R-Studio (", R.version.string, ") on ",
                        format(Sys.time(), "%B %d, %Y at %H:%M:%S"))

  p <- ggplot2::ggplot(org_stats, ggplot2::aes(x = Total_Docs, y = CPP)) +

    # 1. Quadrant Lines
    ggplot2::geom_hline(yintercept = med_cpp, linetype = "dashed", color = "gray60") +
    ggplot2::geom_vline(xintercept = med_docs, linetype = "dashed", color = "gray60") +

    # 2. Quadrant Labels
    ggplot2::annotate("text", x = max(org_stats$Total_Docs), y = max(org_stats$CPP),
                      label = "LEADERS\n(High Vol, High Impact)", hjust=1, vjust=1, color="gray70", size=3, fontface="bold") +
    ggplot2::annotate("text", x = min(org_stats$Total_Docs), y = max(org_stats$CPP),
                      label = "HIGH QUALITY\n(Niche)", hjust=0, vjust=1, color="gray70", size=3, fontface="bold") +

    # 3. Bubbles (Color Mapped via continuous palette)
    ggplot2::geom_point(ggplot2::aes(size = Total_Cites, color = Total_Cites), alpha = 0.85) +

    # 4. Smart Labels (ggrepel prevents overlapping)
    ggrepel::geom_text_repel(ggplot2::aes(label = Final_Org), size = 3, box.padding = 0.5, point.padding = 0.3) +

    # 5. Numerical Palette Color Scale
    ggplot2::scale_color_viridis_c(option = palette, name = "Total Citations") +
    ggplot2::scale_size_continuous(range = c(3, 10), name = "Total Citations") +

    ggplot2::labs(title = "Institution Strategic Performance Matrix",
                  subtitle = paste0("Top ", nrow(org_stats), " Institutions: Volume (X) vs. Impact (Y)"),
                  x = "Productivity (Total Documents)",
                  y = "Impact (Citations per Paper)",
                  caption = footer_text) +

    ggplot2::theme_minimal() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", size = 14),
      panel.grid.minor = ggplot2::element_blank(),
      legend.position = "right"
    )

  return(p)
}
