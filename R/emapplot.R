saveRDS(snakemake, '.emapplot.R.RDS')
snakemake <- readRDS('.emapplot.R.RDS')

library(enrichplot)
library(ggplot2)

clusterProfiler <- readRDS(snakemake@input$clusterProfiler)
terms <- pairwise_termsim(clusterProfiler, showCategory = nrow(clusterProfiler@result))
plot <- emapplot(terms,
                 edge.params = list(min = 0.35),
                 cex.params = list(category_label = 0.6,
                                   category_node = 0.6,
                                   line = 0.25),
                 color = 'NES',
                 node_label = 'group',
                 showCategory = nrow(clusterProfiler@result) / 2)

ggsave(plot, filename = snakemake@output$emapplot, height = 9, width = 9)
