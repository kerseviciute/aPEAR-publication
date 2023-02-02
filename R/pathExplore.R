saveRDS(snakemake, '.pathExplore.R.RDS')
# snakemake <- readRDS('.pathExplore.R.RDS')

library(pathExplore)
library(ggplot2)

clusterProfiler <- readRDS(snakemake@input$clusterProfiler)

set.seed(42)
plot <- enrichmentNetwork(clusterProfiler@result,
                          fontSize = 3,
                          outerCutoff = 0.25,
                          minClusterSize = 5,
                          drawEllipses = TRUE,
                          repelLabels = TRUE) +
  theme(legend.position = 'bottom')

ggsave(plot, filename = snakemake@output$pathExplore, device = 'png', height = 6.5, width = 7)
