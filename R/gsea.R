#'
#' Performs gene set enrichment analysis using the GSEA software.
#'

saveRDS(snakemake, '.gsea.R.RDS')
snakemake <- readRDS('.gsea.R.RDS')

library(glue)

system(glue('rm -rf {snakemake@output$gsea}'))

#
# Run the enrichment analysis using GSEA software and create a datatable of the results
#
gseaSoft <- snakemake@input$soft
gmtFile <- snakemake@input$gmt
rankFile <- snakemake@input$rank

log <- snakemake@log$log

outputDir <- file.path(tempdir(), 'aPEAR')
dir.create(outputDir)

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
  -rnd_seed 4857384 > {log}"
)

system(cmd)

gseaDir <- list.dirs(outputDir, recursive = FALSE)[ 1 ]
system(glue('mkdir -p {dirname(snakemake@output$gsea)}'))
system(glue('mv {gseaDir} {snakemake@output$gsea}'))
