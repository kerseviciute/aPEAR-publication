
rule all:
  input:
    emapplot = 'output/figures/emapplot.png',
    pathExplore = 'output/figures/pathExplore.png'
    # cytoscape = 'output/figures/cytoscape.png',
    # clusterProfiler = 'output/enrichment/clusterProfiler.RDS'

rule gsea:
  input:
    gmt = 'output/temp/human.gmt',
    rank = 'output/temp/rank.rnk',
    soft = ancient('GSEA_4.3.2/gsea-cli.sh')
  output:
    gsea = directory('output/enrichment/gsea')
  log:
    log = 'logs/gsea.log'
  conda: 'env/pathExplore.yml'
  script: 'R/gsea.R'

rule rank:
  output:
    rank = temp('output/temp/rank.rnk')
  conda: 'env/pathExplore.yml'
  script: 'R/prepRank.R'

rule gmt:
  output:
    gmt = temp('output/temp/human.gmt')
  params:
    url = 'http://download.baderlab.org/EM_Genesets/January_01_2023/Human/entrezgene/Human_GOBP_AllPathways_no_GO_iea_January_01_2023_entrezgene.gmt'
  shell:
    """
      wget {params.url} -O {output.gmt}
    """

#
# IMPORTANT: Cytoscape must be running to execute this rule!
#
rule cytoscape:
  input:
    gsea = 'output/enrichment/gsea',
    gmt = 'output/temp/human.gmt',
    filter = ancient('cytoscape/filter.json')
  output:
    image = 'output/figures/cytoscape.png'
  conda: 'env/pathExplore.yml'
  script: 'R/cytoscape.R'

rule clusterProfiler:
  output:
    clusterProfiler = 'output/enrichment/clusterProfiler.RDS'
  conda: 'env/pathExplore.yml'
  script: 'R/clusterProfiler.R'

rule pathExplore:
  input:
    clusterProfiler = 'output/enrichment/clusterProfiler.RDS'
  output:
    pathExplore = 'output/figures/pathExplore.png'
  conda: 'env/pathExplore.yml'
  script: 'R/pathExplore.R'

rule emapplot:
  input:
    clusterProfiler = 'output/enrichment/clusterProfiler.RDS'
  output:
    emapplot = 'output/figures/emapplot.png'
  conda: 'env/pathExplore.yml'
  script: 'R/emapplot.R'
