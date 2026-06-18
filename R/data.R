#' Dataset for bibliometric practice coming from Hospital Management field in patient safety domain.
#'
#' This dataset extracted from "EVOLUTION OF ARTIFICIAL INTELLIGENCE IN PATIENT SAFETY ACROSS SOUTHEAST ASIA: A BIBLIOMETRIC ANALYSIS"
#' \url{https://doi.org/10.53806/iamsph.v7i1.1447}
#'
#' Abstract: This study evaluated the evolution of artificial intelligence (AI) and machine learning in patient safety across Southeast Asia (SEA) to identify regional research dynamics and emerging frontiers. A quantitative bibliometric analysis was conducted using 262 primary documents retrieved from the Scopus database (English-language; published up to December 31, 2025). Document selection was guided by an adaptation of the PRISMA-ScR framework. Key indicators included the Mann-Kendall trend test, Pettitt’s change-point test, and thematic cooccurrence network mapping. Statistical analysis revealed a significant structural shift in 2015 (p < 0.01), marking exponential publication growth and extensive international collaboration (62.2% of documents featuring multi-country co-authorship). Results highlighted a divergence in regional strategies; high-income nations produced high-impact clinical algorithms, while emerging economies prioritized capacity building for resource-constrained systems. Thematic mapping demonstrated a major transitional shift in the literature from traditional, image-based neural networks for diagnostic accuracy toward natural language processing and large language models aimed at addressing clinical documentation and prescribing errors. These publication dynamics map the current academic focus, highlighting the need for future implementation driven clinical validation and regionally adapted regulatory frameworks.
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
#' \url{https://doi.org/10.1051/bioconf/202515404001}
#'
#' Abstract: This study provides a bibliometric analysis of research on herbal medicine and leptospirosis in Southeast Asia from 1973 to 2023. The investigation identified 3,043 documents through a systematic search in the Scopus database using keywords. One hundred forty-seven papers were published across 100 different sources, revealing an annual growth rate of 6.07%, indicating a growing interest in the intersection of herbal medicine and leptospirosis. The study shows significant collaboration, with 935 authors contributing to the body of research and an average of 7.55 co-authors per document. Notably, 40.14% of the publications involve international co-authorship, reflecting the global relevance and collaborative efforts in addressing leptospirosis through herbal remedies. Keyword analysis highlights “leptospirosis,” “leptospira,” and “DNA extraction” as central themes, demonstrating a focus on the genetic and diagnostic aspects of the disease alongside the exploration of plant-based treatments. The research also emphasizes the role of preclinical studies and the chemical analysis of herbal remedies for leptospirosis. The study identifies key contributors to the field, with prolific authors such as Chee HY, Sekawi Z, and Patarakul K leading the research efforts. Malaysia, Thailand, and Japan are highlighted as the most productive countries, significantly contributing to this domain’s research output and citation impact.
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
#' \url{https://doi.org/10.1051/bioconf/202515403005}
#'
#' Abstract: This study presents a bibliometric analysis of research on herbal medicine and snakebite in Southeast Asia, focusing on publications from 1974 to 2023. The investigation involved 205 documents selected using specific keywords in the Scopus database. After applying inclusion criteria such as language and regional focus, the final selection yielded 202 documents across 145 sources. The analysis reveals an annual growth rate of 4.25%, indicating a steady increase in research interest over the past five decades. With contributions from 1,049 authors and an average of 6.08 coauthors per document, the field exhibits a high level of collaboration. Notably, nearly half of the publications (49.5%) involve international coauthorship, underscoring the global significance of the research in this domain. Keyword analysis identified “snakebite,” “venom,” and “medicinal plants” as central themes. The research also emphasizes preclinical studies, which are crucial for understanding the efficacy and safety of herbal remedies for snakebite treatment. The study further identifies key contributors to the field, with prolific authors such as Tan NH, Pithayanukul P, and Gopalakrishnakone P leading the scholarly discourse. Malaysia, Thailand, and Singapore are highlighted as the most productive countries, contributing significantly to the research output and citation impact.
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

#' Dataset from Berlianda Nur Sabilla et all (Herbal Medicine field in Tropical Disease Dengue)
#'
#' This dataset extracted from "Dengue fever and herbal medicine in Indonesia: Trends, collaborations, and research impact (1985-2023)"
#' \url{https://doi.org/10.1051/bioconf/202515403003}
#'
#' Abstract: The research aims to determine the extent to which herbal research in dengue fever through a bibliometric analysis in Scopus databases from 1985 to 2023. Using RStudio with the Bibliometrix package, this study scrutinizes publication patterns, identifies leading institutions, highlights influential authors, and examines keyword trends. Over this period, 122 documents were published across 88 different sources, revealing an annual growth rate of 8.06%. This growth suggests a rising interest in the intersection of herbal medicine and dengue fever, indicating that the research community is increasingly recognizing the potential of herbal treatments. The collaborative nature of this research is underscored by the fact that the average number of co-authors per document is 5.79. Additionally, 21.31% of these publications involve international co-authorship, reflecting a significant level of global collaboration and a shared interest in addressing this persistent health issue. Leading Indonesian institutions, such as Universitas Airlangga and Gajah Mada University, have been at the forefront of this research, making substantial contributions to the scholarly output in this field. Prominent authors, including Sucipto TH and Yohan B, have emerged as key figures. A keyword co-occurrence analysis identified “Aedes aegypti,” “animal model,” and “plant extract” as central themes in the research, which highlights a strong focus on preclinical studies and the chemical analysis of plant-based treatments.
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
"df_herbal_dengue"

#' Dataset from Arista Elda Monica et all (Herbal Medicine field in Tropical Disease Filariasis)
#'
#' This dataset extracted from "Herbal and filariasis in Indonesia: A citation network analysis"
#' \url{https://doi.org/10.1051/bioconf/202515403002}
#'
#' Abstract: This study examines the role of herbal medicine, deeply rooted in Indonesia’s rich culture, as a potential solution for filariasis. The primary goal is to analyze the extent of herbal research related to filariasis through a citation network analysis of studies published in Scopus databases from 1980 to 2023. The study uses RStudio and the Bibliometrix package to assess publication trends, key contributing institutions, influential authors, and keyword patterns. One hundred eighteen documents have been published in 90 sources, with an annual growth rate of 5.95%, indicating a growing interest in herbal filariasis research. The average number of coauthors per document is 4.64, and 34.75% of the publications involve international collaboration, underscoring significant global involvement. Universitas Negeri Surabaya, Universitas Indonesia, and Universitas Gadjah Mada are leading the research efforts in this field, contributing notably to the body of knowledge. Prominent authors like Maizels RM, Djati MS, and Yazdanbach SH play a key role in shaping the academic discourse. The analysis of keyword co-occurrence reveals that “brugia malayi,” “controlled study,” and “ extract” are central themes, reflecting a strong focus on preclinical research and the extraction procedures of plant-based treatments.
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
"df_herbal_filaria"

#' Dataset from Annisa Nur Azizah et all (Herbal Medicine field in Tropical Disease Tuberculosis)
#'
#' This dataset extracted from "Herbal and tuberculosis in Indonesia: Bibliometric analysis"
#' \url{https://doi.org/10.1051/bioconf/202515403001}
#'
#' Abstract: This study explores the herbal status, grounded in Indonesia’s extensive tradition of herbal medicine, to address tuberculosis. The primary aim is to elucidate the extent of herbal research in tuberculosis through a bibliometric analysis of relevant research published in Scopus databases between 1996 and 2023. The study used RStudio, complemented by the Bibliometrix package, to assess publication patterns, contributing institutions, influential authors, and keyword trends. Two hundred-one documents have been published across 138 different sources, with an annual growth rate of 13.83%, suggesting possibilities of growing interest in herbal tuberculosis research. The average number of co-authors per document is 5.65, and 21.89% of the publications involve international co-authorship, highlighting a significant level of global collaboration. Universitas Padjajaran and Airlanga are at the forefront of research in this domain, contributing significantly to the scholarly output. Noteworthy contributions by prolific authors such as Massi MN and Mertaniasih underscore the critical nodes of academic influence. Keyword co-occurrence analysis identified “mycobacterium tuberculosis,” “animal experiment,” and “plant extract” as central themes, highlighting a predominant focus on preclinical research and the chemical analysis of plant-based treatments.
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
"df_herbal_tb"

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
