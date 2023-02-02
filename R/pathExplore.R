saveRDS(snakemake, '.pathExplore.R.RDS')
# snakemake <- readRDS('.pathExplore.R.RDS')

library(pathExplore)
library(ggplot2)

clusterProfiler <- readRDS(snakemake@input$clusterProfiler)

set.seed(42)
plot <- enrichmentNetwork(clusterProfiler@result,
                          fontSize = 2.5,
                          outerCutoff = 0.25,
                          minClusterSize = 5,
                          drawEllipses = TRUE,
                          repelLabels = TRUE)

ggsave(plot, filename = snakemake@output$pathExplore, device = 'png', height = 6, width = 7)
