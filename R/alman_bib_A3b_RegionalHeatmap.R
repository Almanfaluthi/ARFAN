#' Regional Productivity Heatmap (Continent/Region Zoom)
#'
#' @description
#' A variation of the Country Heatmap that focuses on a specific continent
#' or region (e.g., "Asia", "Europe", "ASEAN"). It filters the map coordinates
#' to zoom in on the specific area of interest.
#'
#' @param data A data frame containing bibliographic data.
#' @param region_name String. The focus region. Options: "Asia", "Europe", "Africa", "Americas", "Oceania", or "ASEAN" (default: "Asia").
#' @param affil_col String. Column name for Affiliations.
#' @param low_col Color for low productivity (default: "#d6eaf8").
#' @param high_col Color for high productivity (default: "#c0392b").
#' @param top_n_labels Integer. Jumlah top negara produktif yang ingin ditampilkan pada anotasi peta (default: 5).
#'
#' @importFrom dplyr mutate group_by summarize left_join filter n arrange desc
#' @importFrom ggplot2 ggplot aes geom_polygon scale_fill_gradient labs theme_void coord_fixed annotate element_text theme map_data
#' @importFrom countrycode countrycode
#' @importFrom stringr str_trim
#' @importFrom utils head tail
#' @export
#'
#' @examples
#' \dontrun{
#' # 1. Visualizing Southeast Asia (Top 5)
#' alman_bib_A3b_RegionalHeatmap(df_herbal_leptospirosis, region_name = "ASEAN")
#'
#' # 2. Visualizing Europe with Custom Colors (Top 10)
#' alman_bib_A3b_RegionalHeatmap(
#'   data = df_herbal_leptospirosis,
#'   region_name = "Europe",
#'   high_col = "#27ae60",
#'   top_n_labels = 10
#' )
#' }

alman_bib_A3b_RegionalHeatmap <- function(data,
                                          region_name = "Asia",
                                          affil_col = "Affiliations",
                                          low_col = "#d6eaf8",
                                          high_col = "#c0392b",
                                          top_n_labels = 5) { # <-- Fleksibilitas Top N ditambahkan

  # ==========================================
  # 1. DATA EXTRACTION
  # ==========================================
  if(!affil_col %in% names(data)) stop(paste0("Error: '", affil_col, "' column not found."))

  # Filter non-empty rows flexibly
  df_geo <- data[!is.na(data[[affil_col]]) & data[[affil_col]] != "", , drop = FALSE]
  df_geo[[affil_col]] <- as.character(df_geo[[affil_col]])

  extract_country <- function(x) {
    if(is.na(x) || x == "") return(NA)
    parts <- unlist(strsplit(x, ";"))
    countries <- sapply(parts, function(p) {
      loc_parts <- unlist(strsplit(p, ","))
      # Fleksibel: gunakan resource yang ada saja jika format kacau
      if(length(loc_parts) > 0) {
        return(stringr::str_trim(utils::tail(loc_parts, 1)))
      } else {
        return(NA)
      }
    })
    return(unique(countries[!is.na(countries)]))
  }

  country_list <- lapply(df_geo[[affil_col]], extract_country)
  if(length(country_list) == 0) stop("No valid affiliations found.")

  df_countries <- data.frame(region = unlist(country_list), stringsAsFactors = FALSE)

  # Clean Names
  df_countries$region <- gsub("\\.", "", df_countries$region)
  df_countries$region <- gsub("United States", "USA", df_countries$region)
  df_countries$region <- gsub("United Kingdom", "UK", df_countries$region)
  df_countries$region <- gsub("England", "UK", df_countries$region)
  df_countries$region <- gsub("Korea", "South Korea", df_countries$region)
  df_countries$region <- gsub("Viet Nam", "Vietnam", df_countries$region)
  df_countries$region <- gsub("Russian Federation", "Russia", df_countries$region)

  country_counts <- df_countries %>%
    dplyr::group_by(region) %>%
    dplyr::summarize(Docs = dplyr::n()) %>%
    dplyr::arrange(dplyr::desc(Docs))

  # ==========================================
  # 2. REGIONAL FILTERING
  # ==========================================
  world_map <- ggplot2::map_data("world")

  # Add Continent Info to the Map Data (menggunakan warn = FALSE agar tidak rewel di R CMD check)
  world_map$continent <- countrycode::countrycode(sourcevar = world_map$region,
                                                  origin = "country.name",
                                                  destination = "continent",
                                                  warn = FALSE)

  # Custom Filter Logic
  if(region_name == "ASEAN") {
    asean_countries <- c("Brunei", "Cambodia", "Indonesia", "Laos", "Malaysia",
                         "Myanmar", "Philippines", "Singapore", "Thailand", "Vietnam")
    target_map <- world_map[world_map$region %in% asean_countries, ]
    country_counts <- country_counts[country_counts$region %in% asean_countries, ]

  } else if(region_name == "Americas") {
    target_map <- world_map[world_map$continent %in% c("Americas", "North America", "South America"), ]
  } else {
    target_map <- world_map[world_map$continent == region_name & !is.na(world_map$continent), ]
  }

  if(nrow(target_map) == 0) stop("Could not find map data for the specified region.")

  # Merge Data
  map_plot_data <- dplyr::left_join(target_map, country_counts, by = "region")

  # ==========================================
  # 3. VISUALIZATION
  # ==========================================
  # Calculate stats for the specific region
  total_docs_region <- sum(country_counts$Docs, na.rm = TRUE)

  # Ambil Top N sesuai input parameter
  top_n_df <- utils::head(country_counts[order(-country_counts$Docs),], top_n_labels)
  top_str <- paste(paste0(top_n_df$region, ": ", top_n_df$Docs), collapse = " | ")

  footer_text <- paste0("Generated by R-Studio (", R.version.string, ") on ",
                        format(Sys.time(), "%B %d, %Y at %H:%M:%S"))

  p <- ggplot2::ggplot(map_plot_data, ggplot2::aes(x = long, y = lat, group = group)) +

    # 1. Base Map (Region specific)
    ggplot2::geom_polygon(fill = "#ecf0f1", color = "white", linewidth = 0.2) +

    # 2. Heatmap
    ggplot2::geom_polygon(ggplot2::aes(fill = Docs), color = "gray90", linewidth = 0.1) +

    # 3. Scale
    ggplot2::scale_fill_gradient(name = "Publications",
                                 low = low_col, high = high_col,
                                 na.value = "#ecf0f1",
                                 trans = "log1p",
                                 breaks = scales::breaks_pretty(n = 4)) +

    # 4. Labels
    ggplot2::annotate("text", x = mean(range(target_map$long)), y = min(target_map$lat),
                      label = paste0("Total Region Output: ", total_docs_region, "\nTop ", nrow(top_n_df), ": ", top_str),
                      hjust = 0.5, vjust = -1, size = 3, family = "mono", color = "#2c3e50", fontface = "bold") +

    ggplot2::labs(title = paste("Scientific Production Map:", region_name),
                  subtitle = "Regional distribution of research output",
                  caption = footer_text) +

    ggplot2::coord_fixed(1.3) +
    ggplot2::theme_void() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", size = 14, hjust = 0.5),
      plot.subtitle = ggplot2::element_text(size = 10, color = "gray50", hjust = 0.5),
      legend.position = "right"
    )

  return(p)
}
