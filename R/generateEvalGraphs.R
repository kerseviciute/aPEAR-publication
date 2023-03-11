saveRDS(snakemake, '.evaluate.R.RDS')
# snakemake <- readRDS('.evaluate.R.RDS')

library(tidyverse)
library(data.table)
library(ggpubr)

readRDS(snakemake@input$eval) %>%
  .[ , Size := NULL ] %>%
  .[ , Dunn := round(Dunn, digits = 5) ] %>%
  .[ , Silhouette := round(Silhouette, digits = 5) ] %>%
  .[ , DaviesBouldin := round(DaviesBouldin, digits = 5) ] %>%
  .[ , Dataset := gsub(pattern = 'data/dataset([0-9]+).RDS', replacement = '\\1', x = Dataset) ] %>%
  fwrite(snakemake@output$csv)

cluster <- readRDS(snakemake@input$eval) %>%
  .[ , Size := NULL ]

colors <- list(
  violet = rgb(136, 29, 88, alpha = 1 * 255, maxColorValue = 255),
  red = rgb(238, 58, 39, alpha = 1 * 255, maxColorValue = 255),
  blue = rgb(0, 118, 164, alpha = 1 * 255, maxColorValue = 255),
  cyan = rgb(154, 215, 213, alpha = 1 * 255, maxColorValue = 255)
)
names(colors) <- NULL

p1 <- cluster %>%
  reshape2::melt(variable.name = 'Index') %>%
  setDT %>%
  ggplot(aes(x = Cluster, y = value, color = Cluster, fill = Cluster)) +
  facet_wrap(~Index, scale = 'free_y') +
  geom_boxplot(alpha = 0.25, outlier.alpha = 0) +
  geom_jitter(alpha = 0.45, width = 0.25, height = 0) +
  stat_compare_means(method = 'wilcox.test',
                     size = 2.5,
                     comparisons = list(c('hier', 'markov'), c('markov', 'spectral'), c('hier', 'spectral'))) +
  scale_color_manual(values = unlist(colors)) +
  scale_fill_manual(values = unlist(colors)) +
  theme_bw(base_size = 9) +
  theme(legend.position = 'top',
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))

p2 <- cluster %>%
  reshape2::melt(variable.name = 'Index') %>%
  setDT %>%
  ggplot(aes(x = Similarity, y = value, color = Similarity, fill = Similarity)) +
  facet_wrap(~Index, scale = 'free_y') +
  geom_boxplot(alpha = 0.25, outlier.alpha = 0) +
  geom_jitter(alpha = 0.45, width = 0.25, height = 0) +
  stat_compare_means(method = 'wilcox.test',
                     size = 2.5,
                     comparisons = list(c('cor', 'cosine'), c('cosine', 'jaccard'), c('cor', 'jaccard'))) +
  scale_color_manual(values = unlist(colors)) +
  scale_fill_manual(values = unlist(colors)) +
  theme_bw(base_size = 9) +
  theme(legend.position = 'top',
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))

p3 <- cluster %>%
  reshape2::melt(variable.name = 'Index') %>%
  setDT %>%
  ggplot() +
  facet_wrap(~Index, scale = 'free_y') +
  geom_boxplot(aes(x = Cluster, y = value, color = Similarity, fill = Similarity), alpha = 0.25) +
  scale_color_manual(values = unlist(colors)) +
  scale_fill_manual(values = unlist(colors)) +
  theme_bw(base_size = 9) +
  theme(legend.position = 'top')

ggarrange(
  ggarrange(p1, p2, nrow = 1, ncol = 2, labels = letters[ 1:2 ], font.label = list(size = 12)),
  ggarrange(p3, nrow = 1, ncol = 1, labels = letters[ 3 ], font.label = list(size = 12)),
  nrow = 2, ncol = 1, heights = c(0.6, 0.4)
) %>% ggsave(filename = snakemake@output$png, device = 'png', height = 10, width = 7)
