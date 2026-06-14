
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ARFAN

ARFAN (Academic Research Framework for Author Networks) is a
comprehensive, elegant, and user-friendly R package designed for modern
bibliometric and scientometric analysis.

Bridging the gap between raw citation data (from Scopus, Web of Science,
PubMed, etc.) and publication-ready visualizations, ARFAN provides
researchers with automated tools to map scientific literature, discover
research gaps, and visualize academic networks.

✨ Key Features (In Development): 1. Executive Dashboards: Generate
“One-Page” infographic summaries of your entire dataset. 2. Trend
Analysis: Track publication growth, citations, and topic evolution over
time. 3. Regional Analysis: Map global collaborations and
country-specific research output. 4. Network Mapping: Visualize
co-authorship, bibliographic coupling, and citation hubs. 5. Text
Mining: Generate beautiful word clouds and keyword co-occurrence
networks.

## Installation

You can install the development version of ARFAN like so:
‘devtools::install_github(“Almanfaluthi/ARFAN”)’

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(ARFAN)
alman_bib_A0_ExecutiveSummary(data = df_patientsafety)
```

<img src="man/figures/README-example-1.png" width="100%" />

``` r
alman_bib_A0_ExecutiveSummary(data = df_leadership)
```

<img src="man/figures/README-example-2.png" width="100%" />
