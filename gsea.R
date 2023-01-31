library(tidyverse)
library(DOSE)
library(glue)
library(GSA)
data(geneList)

#
# Delete old results and recreate the directory
#
if (file.exists(file.path(getwd(), 'gsea'))) {
  unlink(file.path(getwd(), 'gsea'), recursive = TRUE, force = TRUE)
}

dir.create(file.path(getwd(), 'gsea'), showWarnings = FALSE)
setwd(file.path(getwd(), 'gsea'))

#
# Prepare the gene list for GSEA software
#
rankFile <- file.path(getwd(), 'geneList.rnk')
geneList %>%
  tibble::enframe(name = 'Gene', value = 'Rank') %>%
  fwrite(rankFile, sep = '\t', row = F, quote = F)

#
# Download the GMT file
#
gmtFile <- file.path(getwd(), 'human.gmt')
download.file(url = 'http://download.baderlab.org/EM_Genesets/January_01_2023/Human/entrezgene/Human_GOBP_AllPathways_no_GO_iea_January_01_2023_entrezgene.gmt',
              destfile = gmtFile)

outputDir <- file.path(getwd(), 'results')
dir.create(outputDir, showWarnings = FALSE)

#
# Download the GSEA cli software (all platforms) from http://www.gsea-msigdb.org/gsea/downloads.jsp
# and install to this location:
#
gseaSoft <- file.path(getwd(), '../GSEA_4.3.2/gsea-cli.sh')

cmd <- glue(
  "{gseaSoft} GSEAPreranked \\
  -gmx {gmtFile} \\
  -nperm 1000 \\
  -scoring_scheme 'classic' \\
  -norm 'meandiv' \\
  -rnk {rankFile} \\
  -out {outputDir} \\
  -set_min 10 \\
  -set_max 200 \\
  -rnd_seed 4857384 > enrichment_gsea.log"
)

#
# Run the enrichment analysis using GSEA software and create a datatable of the results
#
system(cmd)

gseaResults <- list.dirs(file.path(getwd(), 'results'), recursive = FALSE)
gseaFiles <- list.files(gseaResults) %>%
  grep(pattern = 'gsea_report_for_na_', value = TRUE) %>%
  grep(pattern = '.tsv', value = TRUE)

enrichment <- foreach(file = gseaFiles, .combine = rbind) %do% {
  fread(file.path(gseaResults, file)) %>%
    setDT %>%
    .[ , V12 := NULL ]
} %>%
  setnames(c('ID', 'MSigDB', 'Details', 'Size', 'ES', 'NES', 'NOM', 'FDR', 'FWER', 'MaxRank', 'LeadingEdge')) %>%
  .[ , Details := NULL ] %>%
  .[ , MSigDB := NULL ]

#
# Parse the GMT file and merge with enrichment results to obtain the gene lists for all pathways
#
gmt <- purrr::quietly(GSA.read.gmt)(gmtFile)$result
dt <- foreach(i = seq_along(gmt[[1]]), .combine = rbind) %do% {
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

enrichment <- enrichment %>%
  merge(dt, by = 'ID') %>%
  .[ Description != 'untitled' ]

setwd('..')
saveRDS(enrichment, 'enrichment.RDS')
