#' Dataset for bibliometric practice coming from Hospital Management field in patient safety domain.
#'
#' This dataset extracted from "EVOLUTION OF ARTIFICIAL INTELLIGENCE IN PATIENT SAFETY ACROSS SOUTHEAST ASIA: A BIBLIOMETRIC ANALYSIS"
#' \url{https://doi.org/10.53806/iamsph.v7i1.1447} Abstract: This study evaluated the evolution of artificial intelligence (AI) and machine learning in patient safety across Southeast Asia (SEA) to identify regional research dynamics and emerging frontiers. A quantitative bibliometric analysis was conducted using 262 primary documents retrieved from the Scopus database (English-language; published up to December 31, 2025). Document selection was guided by an adaptation of the PRISMA-ScR framework. Key indicators included the Mann-Kendall trend test, Pettitt’s change-point test, and thematic cooccurrence network mapping. Statistical analysis revealed a significant structural shift in 2015 (p < 0.01), marking exponential publication growth and extensive international collaboration (62.2% of documents featuring multi-country co-authorship). Results highlighted a divergence in regional strategies; high-income nations produced high-impact clinical algorithms, while emerging economies prioritized capacity building for resource-constrained systems. Thematic mapping demonstrated a major transitional shift in the literature from traditional, image-based neural networks for diagnostic accuracy toward natural language processing and large language models aimed at addressing clinical documentation and prescribing errors. These publication dynamics map the current academic focus, highlighting the need for future implementation driven clinical validation and regionally adapted regulatory frameworks.
#'
#' @format Sebuah data frame dengan 500 baris dan 10 kolom:
#' \describe{
#'   \item{Authors}{Nama penulis artikel, dipisahkan dengan titik koma (;)}
#'   \item{Title}{Judul artikel publikasi}
#'   \item{Year}{Tahun artikel diterbitkan}
#'   \item{Cited by}{Jumlah total sitasi yang diterima artikel tersebut}
#'   \item{Affiliations}{Afiliasi institusi dan negara asal penulis}
#'   \item{Keywords}{Kata kunci yang digunakan dalam artikel}
#' }
#' @source Data diekstrak dari \url{https://www.scopus.com/}
"df_patientsafety"

#' Dataset for bibliometric practice coming from Ade Dian Shah Putri et all (Herbal Medicine field in Tropical Disease Leptospirosis)
#'
#' This dataset extracted from "Herbal medicine and leptospirosis in Southeast Asia: A comprehensive bibliometric analysis (1973-2023)"
#' \url{https://doi.org/10.1051/bioconf/202515404001} Abstract: This study provides a bibliometric analysis of research on herbal medicine and leptospirosis in Southeast Asia from 1973 to 2023. The investigation identified 3,043 documents through a systematic search in the Scopus database using keywords. One hundred forty-seven papers were published across 100 different sources, revealing an annual growth rate of 6.07%, indicating a growing interest in the intersection of herbal medicine and leptospirosis. The study shows significant collaboration, with 935 authors contributing to the body of research and an average of 7.55 co-authors per document. Notably, 40.14% of the publications involve international co-authorship, reflecting the global relevance and collaborative efforts in addressing leptospirosis through herbal remedies. Keyword analysis highlights “leptospirosis,” “leptospira,” and “DNA extraction” as central themes, demonstrating a focus on the genetic and diagnostic aspects of the disease alongside the exploration of plant-based treatments. The research also emphasizes the role of preclinical studies and the chemical analysis of herbal remedies for leptospirosis. The study identifies key contributors to the field, with prolific authors such as Chee HY, Sekawi Z, and Patarakul K leading the research efforts. Malaysia, Thailand, and Japan are highlighted as the most productive countries, significantly contributing to this domain’s research output and citation impact.
#'
#' @format Sebuah data frame dengan 156 baris dan 46 kolom:
#' \describe{
#'   \item{Authors}{Nama penulis artikel, dipisahkan dengan titik koma (;)}
#'   \item{Title}{Judul artikel publikasi}
#'   \item{Year}{Tahun artikel diterbitkan}
#'   \item{Cited by}{Jumlah total sitasi yang diterima artikel tersebut}
#'   \item{Affiliations}{Afiliasi institusi dan negara asal penulis}
#'   \item{Keywords}{Kata kunci yang digunakan dalam artikel}
#' }
#' @source Data diekstrak dari \url{https://www.scopus.com/}
"df_herbal_leptospirosis"

#' Dataset for bibliometric practice coming from Ilham Jaluludin et all (Herbal Medicine field in Tropical Disease Snake bite)
#'
#' This dataset extracted from "Herbal medicine and snakebite research in Southeast Asia: A bibliometric analysis (1974-2024)"
#' \url{https://doi.org/10.1051/bioconf/202515403005} Abstract: This study presents a bibliometric analysis of research on herbal medicine and snakebite in Southeast Asia, focusing on publications from 1974 to 2023. The investigation involved 205 documents selected using specific keywords in the Scopus database. After applying inclusion criteria such as language and regional focus, the final selection yielded 202 documents across 145 sources. The analysis reveals an annual growth rate of 4.25%, indicating a steady increase in research interest over the past five decades. With contributions from 1,049 authors and an average of 6.08 coauthors per document, the field exhibits a high level of collaboration. Notably, nearly half of the publications (49.5%) involve international coauthorship, underscoring the global significance of the research in this domain. Keyword analysis identified “snakebite,” “venom,” and “medicinal plants” as central themes. The research also emphasizes preclinical studies, which are crucial for understanding the efficacy and safety of herbal remedies for snakebite treatment. The study further identifies key contributors to the field, with prolific authors such as Tan NH, Pithayanukul P, and Gopalakrishnakone P leading the scholarly discourse. Malaysia, Thailand, and Singapore are highlighted as the most productive countries, contributing significantly to the research output and citation impact.
#'
#' @format Sebuah data frame dengan 156 baris dan 46 kolom:
#' \describe{
#'   \item{Authors}{Nama penulis artikel, dipisahkan dengan titik koma (;)}
#'   \item{Title}{Judul artikel publikasi}
#'   \item{Year}{Tahun artikel diterbitkan}
#'   \item{Cited by}{Jumlah total sitasi yang diterima artikel tersebut}
#'   \item{Affiliations}{Afiliasi institusi dan negara asal penulis}
#'   \item{Keywords}{Kata kunci yang digunakan dalam artikel}
#' }
#' @source Data diekstrak dari \url{https://www.scopus.com/}
"df_herbal_snakebite"

#' Dataset for bibliometric practice coming from Hospital Management field in Hospital Leadership.
#'
#' @format Sebuah data frame dengan 500 baris dan 10 kolom:
#' \describe{
#'   \item{Authors}{Nama penulis artikel, dipisahkan dengan titik koma (;)}
#'   \item{Title}{Judul artikel publikasi}
#'   \item{Year}{Tahun artikel diterbitkan}
#'   \item{Cited by}{Jumlah total sitasi yang diterima artikel tersebut}
#'   \item{Affiliations}{Afiliasi institusi dan negara asal penulis}
#'   \item{Keywords}{Kata kunci yang digunakan dalam artikel}
#' }
#' @source Data diekstrak dari \url{https://www.scopus.com/}
"df_leadership"
