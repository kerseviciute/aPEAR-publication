saveRDS(snakemake, '.aPEARGSEA.R.RDS')
# snakemake <- readRDS('.aPEARGSEA.R.RDS')

library(GSA)
library(data.table)
library(foreach)
library(tidyverse)
library(devtools)
devtools::install_github('https://github.com/ievaKer/aPEAR')
library(aPEAR)

#
# Parse GMT file
#
gmt <- purrr::quietly(GSA.read.gmt)(snakemake@input$gmt)$result
gmt <- foreach(i = seq_along(gmt[[1]]), .combine = rbind) %do% {
  description <- gmt$geneset.description[[i]] %>%
    gsub('_', ' ', .) %>%
    str_to_title()
  geneset <- gmt$genesets[[i]] %>% head(-1)
  genes <- paste(geneset, collapse = '/')
  size <- length(geneset)

  data.table(ID = gmt$geneset.names[[i]],
             Description = description,
             pathwayGenes = genes,
             size = size)
}

#
# Parse enrichment results
#
files <- list.files(snakemake@input$gsea) %>%
  .[ grepl('gsea_report_for_na_', .) ] %>%
  .[ grep('.tsv', .) ]

enrichment <- foreach(file = files, .combine = rbind) %do% {
  fread(file.path(snakemake@input$gsea, file)) %>%
    setDT
} %>%
  .[ , V12 := NULL ] %>%
  setnames(c('ID', 'MSigDB', 'Details', 'Size', 'ES', 'NES', 'NOM', 'FDR', 'FWER', 'MaxRank', 'LeadingEdge')) %>%
  .[ , Details := NULL ] %>%
  .[ , MSigDB := NULL ]

data <- enrichment %>%
  merge(gmt, by = 'ID') %>%
  .[ Description != 'untitled' ] %>%
  .[ FDR < 0.01 ] %>%
  as.data.frame

set.seed(5348953)
plot <- aPEAR::enrichmentNetwork(data,
                                       simMethod = 'jaccard',
                                       clustMethod = 'markov',
                                       colorBy = 'NES',
                                       nodeSize = 'size',
                                       innerCutoff = 0.2,
                                       fontSize = 2.5,
                                       minClusterSize = 15,
                                       verbose = TRUE,
                                       drawEllipses = FALSE) +
  xlim(-20, 20)

ggsave(plot, filename = snakemake@output$aPEAR, device = 'png', height = 6, width = 7)