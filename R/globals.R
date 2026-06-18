# Declare global variables to suppress R CMD check notes
# These are primarily column names used in non-standard evaluation (dplyr/ggplot2)

if (getRversion() >= "2.15.1") {
  utils::globalVariables(c(
    "Year", "Freq", "Item", "Cites", "Target_Cites",
    "Pubs", "Total_Cites", "Country","Institution",
    "frac_score", "Fractional_Articles", "Total_Articles",
    ".", "long", "lat", "group", "region", "Docs",
    "Total_Citations", "Total_Docs", "n_SCP", "n_MCP", "Type", "Count",
    "Country", "country_list", "collab_type", "Final_Org", "CPP",
    "Journal", "Journal_Display", "DocID", "Keyword", "Freq", "Keyword.x",
    "Keyword.y", "Source", "Target", "Weight", "name", "Community",
    "Betweenness", "Degree", "nodes", "Year_Min", "Year_Q1", "Year_Med",
    "Year_Q3", "Year_Max", "Duration"
  ))
}
