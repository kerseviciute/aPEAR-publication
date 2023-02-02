saveRDS(snakemake, '.clusterProfiler.R.RDS')
# snakemake <- readRDS('.clusterProfiler.R.RDS')

library(DOSE)
library(clusterProfiler)
library(org.Hs.eg.db)
data(geneList)

enrich <- gseGO(geneList,
                OrgDb = org.Hs.eg.db,
                ont = 'BP',
                seed = TRUE,
                pvalueCutoff = 0.01)

saveRDS(enrich, snakemake@output$clusterProfiler)
