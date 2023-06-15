
library(png)
library(grid)
library(gridExtra)

library(jpeg)
library(ggpubr)
library(ggplot2)

plot1 <- readJPEG('output/figures_cropped/emapplot.jpeg')
plot2 <- readJPEG('output/figures_cropped/aPEAR.jpeg')

plot <- ggarrange(rasterGrob(plot1), rasterGrob(plot2), nrow = 2, ncol = 1, labels = letters[ 1:2 ])

ggsave(plot, filename = 'supplementary_figure_1.png', width = 5.2, height = 8, bg = 'white')




plot1 <- readJPEG('output/figures_cropped/cytoscape_dataset1.jpeg')
plot2 <- readJPEG('output/figures_cropped/aPEAR_GSEA_dataset1.jpeg')

plot <- ggarrange(rasterGrob(plot1), rasterGrob(plot2), nrow = 2, ncol = 1, labels = letters[ 1:2 ])

ggsave(plot, filename = 'supplementary_figure_2.png', width = 7, height = 8, bg = 'white')



plot1 <- readJPEG('output/figures_cropped/cytoscape_dataset2.jpeg')
plot2 <- readJPEG('output/figures_cropped/aPEAR_GSEA_dataset2.jpeg')

plot <- ggarrange(rasterGrob(plot1), rasterGrob(plot2), nrow = 2, ncol = 1, labels = letters[ 1:2 ])

ggsave(plot, filename = 'supplementary_figure_3.png', width = 6.5, height = 8, bg = 'white')



plot1 <- readJPEG('output/figures_cropped/cytoscape_dataset3.jpeg')
plot2 <- readJPEG('output/figures_cropped/aPEAR_GSEA_dataset3.jpeg')

plot <- ggarrange(rasterGrob(plot1), rasterGrob(plot2), nrow = 2, ncol = 1, labels = letters[ 1:2 ])

ggsave(plot, filename = 'supplementary_figure_4.png', width = 6.5, height = 8, bg = 'white')
