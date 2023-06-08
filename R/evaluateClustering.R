saveRDS(snakemake, '.evaluateClustering.R.RDS')
# snakemake <- readRDS('.evaluateClustering.R.RDS')

library(data.table)
library(tidyverse)
library(foreach)
library(clusterCrit)
library(doParallel)
library(glue)
library(devtools)

devtools::install_gitlab('vugene/aPEAR')
library(aPEAR)

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
    foreach(clustMethod = clustering, .combine = rbind, .multicombine = TRUE) %do% {
      message(glue("{dataset} {simMethod} {clustMethod} {nrow(data)}"))

      # Find clusters in the similarity matrix
      # Markov clustering may fail, in that case return no clusters.
      clusters <- tryCatch({
        set.seed(24985034)
        findPathClusters(data, similarity = simMethod, cluster = clustMethod)
      }, error = \(e) {
        NULL
      })

      if (!is.null(clusters)) {
        sim <- clusters$similarity
        clusters <- clusters$clusters %>% tibble::deframe() %>% as.factor()

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
}

saveRDS(eval, snakemake@output$eval)
