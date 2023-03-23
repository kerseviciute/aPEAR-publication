saveRDS(snakemake, '.aPEAR.R.RDS')
# snakemake <- readRDS('.aPEAR.R.RDS')

library(ggplot2)
devtools::install_github('https://github.com/ievaKer/aPEAR')
library(aPEAR)

clusterProfiler <- readRDS(snakemake@input$clusterProfiler)

set.seed(42)
plot <- enrichmentNetwork(clusterProfiler@result,
                          fontSize = 2.5,
                          outerCutoff = 0.25,
                          drawEllipses = TRUE,
                          repelLabels = TRUE)

ggsave(plot, filename = snakemake@output$aPEAR, device = 'png', height = 6, width = 7)
