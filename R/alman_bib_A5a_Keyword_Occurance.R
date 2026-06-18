#' Ultimate Keyword Network (Visual + In-Graph Stats)
#'
#' @description
#' Generates a professional network map AND calculates rigorous network statistics.
#' The statistics (Density, Modularity, Diameter) are annotated directly
#' inside the plot (top-left) without borders for a cleaner look.
#'
#' @param data A data frame containing bibliographic data.
#' @param keyword_col String. Column name for keywords.
#' @param top_n Integer. Number of top keywords (default: 15).
#' @param min_edge Integer. Minimum edge weight (default: 2).
#' @param remove_terms Vector. Keywords to exclude.
#' @param palette String. Color palette.
#'
#' @importFrom dplyr mutate select filter group_by summarize pull inner_join arrange desc n row_number
#' @importFrom stringr str_to_lower str_trim
#' @importFrom igraph graph_from_data_frame cluster_louvain membership edge_density modularity diameter mean_distance
#' @importFrom ggraph ggraph geom_edge_link geom_node_point geom_node_text theme_graph scale_edge_width
#' @importFrom tidygraph as_tbl_graph activate centrality_betweenness centrality_degree as_tibble
#' @importFrom tidyr separate_rows
#' @importFrom rlang sym !!
#' @importFrom ggplot2 aes annotate scale_size_continuous scale_fill_viridis_d scale_fill_brewer labs theme
#' @importFrom utils head
#' @export
#' @examples
#' \dontrun{
#' # The "Plasma" Look (Professional/Darker)
#' alman_bib_A5a_Keyword_Occurance(df_herbal_dengue, palette = "plasma")
#'
#' # The "Viridis" Look (Colorblind Friendly)
#' alman_bib_A5a_Keyword_Occurance(df_herbal_dengue)
#'
#' # Standard ColorBrewer Palette
#' alman_bib_A5a_Keyword_Occurance(df_herbal_dengue, palette = "Set1")
#' }
alman_bib_A5a_Keyword_Occurance <- function(data,
                                            keyword_col = "Author.Keywords",
                                            top_n = 15,
                                            min_edge = 2,
                                            remove_terms = c("article", "human", "priority journal", "review", "study",
                                                             "systematic review", "meta-analysis", "adult", "male", "female"),
                                            palette = "viridis") {

  # ==========================================
  # 1. DATA PREPARATION
  # ==========================================
  if(!keyword_col %in% names(data)) stop(paste0("Error: '", keyword_col, "' column not found."))

  df_keywords <- data %>%
    dplyr::mutate(DocID = dplyr::row_number()) %>%
    dplyr::select(DocID, Keyword = !!rlang::sym(keyword_col)) %>%
    dplyr::filter(!is.na(Keyword) & Keyword != "") %>%
    tidyr::separate_rows(Keyword, sep = ";") %>%
    dplyr::mutate(Keyword = stringr::str_trim(stringr::str_to_lower(Keyword))) %>%
    dplyr::filter(Keyword != "")

  if(!is.null(remove_terms)) {
    df_keywords <- df_keywords %>% dplyr::filter(!Keyword %in% stringr::str_to_lower(remove_terms))
  }

  top_keywords_df <- df_keywords %>%
    dplyr::group_by(Keyword) %>%
    dplyr::summarize(Freq = dplyr::n()) %>%
    dplyr::arrange(dplyr::desc(Freq))

  # Use head() instead of top_n() for safe dispatch
  top_keywords <- utils::head(top_keywords_df, top_n) %>%
    dplyr::pull(Keyword)

  df_filtered <- df_keywords %>% dplyr::filter(Keyword %in% top_keywords)

  edge_list <- df_filtered %>%
    dplyr::inner_join(df_filtered, by = "DocID") %>%
    dplyr::filter(Keyword.x < Keyword.y) %>%
    dplyr::group_by(Source = Keyword.x, Target = Keyword.y) %>%
    dplyr::summarize(Weight = dplyr::n(), .groups = "drop") %>%
    dplyr::filter(Weight >= min_edge)

  if(nrow(edge_list) == 0) stop("Network Empty. Adjust params (try lowering min_edge or increasing top_n).")

  # ==========================================
  # 2. STATISTICAL CALCULATIONS
  # ==========================================
  g <- igraph::graph_from_data_frame(edge_list, directed = FALSE)

  # A. Clustering
  comm <- igraph::cluster_louvain(g)

  # B. Global Metrics
  net_density <- igraph::edge_density(g)
  net_modularity <- igraph::modularity(comm)
  net_diameter <- igraph::diameter(g)

  global_stats <- data.frame(
    Metric = c("Network Density", "Modularity (Clustering)", "Network Diameter", "Avg Path Length"),
    Value = c(round(net_density, 3),
              round(net_modularity, 3),
              net_diameter,
              round(igraph::mean_distance(g), 2))
  )

  # --- Create Stats Text String for Annotation ---
  stats_label <- paste0(
    "Network Statistics:\n",
    "1.Density: ", round(net_density, 3), "\n",
    "2.Modularity: ", round(net_modularity, 3), "\n",
    "3.Diameter: ", net_diameter
  )

  # C. Node Metrics
  tg <- tidygraph::as_tbl_graph(g) %>%
    tidygraph::activate(nodes) %>%
    dplyr::mutate(
      Community = as.factor(igraph::membership(comm)),
      Betweenness = tidygraph::centrality_betweenness(),
      Degree = tidygraph::centrality_degree()
    ) %>%
    dplyr::filter(Degree > 0)

  top_nodes_df <- tg %>%
    tidygraph::as_tibble() %>%
    dplyr::arrange(dplyr::desc(Betweenness)) %>%
    dplyr::select(name, Community, Betweenness, Degree) %>%
    utils::head(10)

  # ==========================================
  # 3. VISUALIZATION
  # ==========================================
  footer_text <- paste0("Generated by R-Studio (", R.version.string, ") on ",
                        format(Sys.time(), "%B %d, %Y at %H:%M:%S"))

  set.seed(999)

  p <- ggraph::ggraph(tg, layout = "graphopt", charge = 0.02) +
    ggraph::geom_edge_link(ggplot2::aes(width = Weight), color = "gray90", alpha = 0.5, show.legend = FALSE) +

    ggraph::geom_node_point(ggplot2::aes(size = Betweenness, fill = Community), shape = 21, color = "white", stroke = 1.5) +

    ggraph::geom_node_text(ggplot2::aes(label = name), repel = TRUE, size = 3.5, fontface = "bold", color = "#2c3e50",
                           bg.color = "white", bg.r = 0.15) +

    # --- In-Graph Annotation (Top Left, No Border) ---
    ggplot2::annotate("text", x = -Inf, y = Inf, label = stats_label,
                      hjust = -0.1, vjust = 1.1, size = 3, fontface = "italic", color = "gray40") +
    # ------------------------------------------------------

    ggraph::scale_edge_width(range = c(0.2, 2)) +
    ggplot2::scale_size_continuous(range = c(3, 12)) +

    # Safely handle the conditional palette mapping without breaking ggplot flow
    ggplot2::labs(title = "Co-occurance Network Analysis",
                  subtitle = paste0("Nodes sized by Betweenness Centrality (Bridge Power)"),
                  caption = footer_text,
                  fill = "Cluster") +

    ggraph::theme_graph(base_family = "sans", background = "white") +
    ggplot2::theme(legend.position = "bottom")

  # Apply the conditional palette mapping safely outside the main plotting block
  if(palette %in% c("viridis", "plasma", "magma", "inferno", "cividis")) {
    p <- p + ggplot2::scale_fill_viridis_d(option = palette)
  } else {
    p <- p + ggplot2::scale_fill_brewer(palette = palette)
  }

  # RETURN LIST
  return(list(
    plot = p,
    global_stats = global_stats,
    top_nodes = top_nodes_df
  ))
}
