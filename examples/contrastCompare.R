#
# A way to compare enrichment results between various contrasts.
#

detach('package:pathExplore', unload = TRUE)
library(pathExplore)
library(data.table)
library(dplyr)
library(pheatmap)

severe <- readRDS('severe.RDS')
moderate <- readRDS('moderate.RDS')
mild <- readRDS('mild.RDS')

dt <- severe[ , list(ID, SevereNES = NES, SevereFDR = FDR, Description, pathwayGenes, size) ] %>%
  merge(moderate[ , list(ID, ModerateNES = NES, ModerateFDR = FDR, Description, pathwayGenes, size) ], by = c('ID', 'Description', 'pathwayGenes', 'size'), all = TRUE) %>%
  merge(mild[ , list(ID, MildNES = NES, MildFDR = FDR, Description, pathwayGenes, size) ], by = c('ID', 'Description', 'pathwayGenes', 'size'), all = TRUE) %>%
  na.omit %>%
  as.data.frame

results <- enrichmentNetwork(dt,
                             drawEllipses = TRUE,
                             clustMethod = 'markov',
                             clustNameMethod = 'pagerank',
                             repelLabels = FALSE,
                             fontSize = 3,
                             colorBy = 'MildNES',
                             nodeSize = 'size',
                             plotOnly = FALSE)

nes <- dt %>%
  as.data.table %>%
  merge(results$clusters, by.x = 'Description', by.y = 'ID') %>%
  .[ , list(Severe = mean(SevereNES), Moderate = mean(ModerateNES), Mild = mean(MildNES)), by = Cluster ]

x <- nes[ , list(Severe, Moderate, Mild) ] %>%
  as.matrix
rownames(x) <- nes[ , Cluster ]

pheatmap(x)


