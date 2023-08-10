saveRDS(snakemake, '.clusterProfiler.R.RDS')
# snakemake <- readRDS('.clusterProfiler.R.RDS')

library(DOSE)
library(clusterProfiler)
library(org.Hs.eg.db)
data(geneList)

set.seed(28357934)
enrich <- gseGO(geneList,
                OrgDb = org.Hs.eg.db,
                ont = 'CC')

saveRDS(enrich, snakemake@output$clusterProfiler)
