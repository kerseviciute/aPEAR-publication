saveRDS(snakemake, '.cytoscape.R.RDS')
# snakemake <- readRDS('.cytoscape.R.RDS')

library(RCy3)
library(tools)
library(dplyr)
library(glue)

cytoscapePing()
closeSession(FALSE)

rootFolder <- file_path_as_absolute(snakemake@input$gsea)
gmtFile <- file_path_as_absolute(snakemake@input$gmt)
filterFile <- file_path_as_absolute(snakemake@input$filter)

#################################
# Create enrichment map
#################################
glue(
  'enrichmentmap mastermap \\
   rootFolder={rootFolder} \\
   coefficients=COMBINED \\
   qvalue=0.05 \\
   similaritycutoff=0.85 \\
   filterByExpressions=FALSE \\
   commonGMTFile={gmtFile}'
) %>% commandsGET

#################################
# Filter out clusters with very few nodes
#################################
importFilters(filename = filterFile)
applyFilter(filter.name = 'Node filter')
selectEdgesAdjacentToSelectedNodes()
deleteSelectedEdges()
deleteSelectedNodes()

#################################
# Annotate the clusters
#################################
commandsGET('autoannotate annotate-clusterBoosted labelColumn=EnrichmentMap::GS_DESCR')
commandsGET('autoannotate layout layout=cose_group')

# This takes time, but the API returns immediately. Sleep for 15 sec and hope
# that the annotation is complete in this time
Sys.sleep(15)

nodes <- getAllNodes()
setNodeLabelBypass(node.names = nodes, new.labels = '')

fitContent()

Sys.sleep(15)

system(glue('mkdir -p {dirname(snakemake@output$image)}'))
exportImage(filename = file.path(getwd(), snakemake@output$image), type = "PNG")
