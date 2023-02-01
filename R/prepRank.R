saveRDS(snakemake, '.prepRank.R.RDS')
snakemake <- readRDS('.prepRank.R.RDS')

library(data.table)
library(tidyverse)
library(DOSE)
data(geneList)

geneList %>%
  tibble::enframe(name = 'Gene', value = 'Rank') %>%
  fwrite(snakemake@output$rank, sep = '\t', row = F, quote = F)
