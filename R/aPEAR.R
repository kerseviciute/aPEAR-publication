saveRDS(snakemake, '.aPEAR.R.RDS')
# snakemake <- readRDS('.aPEAR.R.RDS')

library(ggplot2)
devtools::install_gitlab('vugene/aPEAR')
library(aPEAR)

clusterProfiler <- readRDS(snakemake@input$clusterProfiler)

set.seed(42)
plot <- enrichmentNetwork(clusterProfiler@result,
                          fontSize = 2.5,
                          outerCutoff = 0.25,
                          drawEllipses = TRUE,
                          repelLabels = TRUE)

seed <- .Random.seed
set.seed(seed)
ggsave(plot, filename = snakemake@output$aPEAR, device = 'png', height = 6, width = 7)

set.seed(seed)
ggsave(plot, filename = snakemake@output$tiff, device = 'tiff', height = 6, width = 7, dpi = 300)
