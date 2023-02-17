saveRDS(snakemake, '.evaluateClustering.R.RDS')
# snakemake <- readRDS('.evaluateClustering.R.RDS')

library(data.table)
library(tidyverse)
library(foreach)
library(clusterCrit)
library(pathExplore)
library(doParallel)
library(glue)

# Will process different datasets separately
doParallel::registerDoParallel(cores = snakemake@input$threads)

# All implemented clustering and similarity methods
clustering <- list('markov', 'hier', 'spectral')
similarity <- list('jaccard', 'cosine', 'cor')

size <- as.numeric(snakemake@wildcards$size)

eval <- foreach(dataset = snakemake@input$datasets, .combine = rbind, .multicombine = TRUE) %dopar% {
  data <- readRDS(dataset) %>%
    .[ 1:size, ]

  foreach(simMethod = similarity, .combine = rbind, .multicombine = TRUE) %do% {
    # Calculate similarity matrix
    sim <- pathwaySimilarity(data, geneCol = 'pathwayGenes', method = simMethod)

    foreach(clustMethod = clustering, .combine = rbind, .multicombine = TRUE) %do% {
      message(glue("{dataset} {simMethod} {clustMethod} {nrow(data)}"))

      # Find clusters in the similarity matrix
      # Markov clustering may fail, in that case return no clusters.
      clusters <- tryCatch({
        findClusters(sim, method = clustMethod, nameMethod = 'none')
      }, error = \(e) {
        list()
      })

      # In the similarity matrix, keep only pathways that have a cluster assigned
      simClust <- sim[ names(clusters), names(clusters) ]

      # Calculate cluster scores
      clusters <- as.integer(clusters)
      scores <- clusterCrit::intCriteria(simClust, clusters, c('Dunn', 'Silhouette', 'Davies_Bouldin'))

      data.table(Dataset = dataset,
                 Cluster = clustMethod,
                 Similarity = simMethod,
                 Size = size,
                 Dunn = scores$dunn,
                 Silhouette = scores$silhouette,
                 DaviesBouldin = scores$davies_bouldin)
    }
  }
}

saveRDS(eval, snakemake@output$eval)
