# Declare global variables to suppress R CMD check notes
# These are primarily column names used in non-standard evaluation (dplyr/ggplot2)

if (getRversion() >= "2.15.1") {
  utils::globalVariables(c(
    "Year", "Freq", "Item", "Cites", "Target_Cites",
    "Pubs", "Total_Cites", "Country","Institution",
    "frac_score", "Fractional_Articles", "Total_Articles",
    ".", "long", "lat", "group", "region", "Docs"
  ))
}
