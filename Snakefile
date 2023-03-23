
rule all:
  input:
    emapplot = 'output/figures/emapplot.png',
    aPEAR = 'output/figures/aPEAR.png',
    aPEARGSEA = 'output/figures/aPEARGSEA.png',
    cytoscape = 'output/figures/cytoscape.png',
    csv = 'output/evaluation/clustering_100.csv',
    clusterQuality = 'output/evaluation/clustering_100.png'

rule gsea:
  input:
    gmt = 'output/enrichment/gmt/human.gmt',
    rank = 'output/enrichment/rank.rnk',
    soft = ancient('GSEA_4.3.2/gsea-cli.sh')
  output:
    gsea = directory('output/enrichment/gsea')
  log:
    log = 'logs/gsea.log'
  conda: 'env/aPEAR.yml'
  script: 'R/gsea.R'

rule rank:
  output:
    rank = 'output/enrichment/rank.rnk'
  conda: 'env/aPEAR.yml'
  script: 'R/prepRank.R'

rule gmt:
  output:
    gmt = 'output/enrichment/gmt/human.gmt'
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
    gmt = 'output/enrichment/gmt/human.gmt',
    filter = ancient('cytoscape/filter.json')
  output:
    image = 'output/figures/cytoscape.png'
  conda: 'env/aPEAR.yml'
  script: 'R/cytoscape.R'

rule clusterProfiler:
  output:
    clusterProfiler = 'output/enrichment/clusterProfiler.RDS'
  conda: 'env/aPEAR.yml'
  script: 'R/clusterProfiler.R'

rule aPEAR:
  input:
    clusterProfiler = 'output/enrichment/clusterProfiler.RDS'
  output:
    aPEAR = 'output/figures/aPEAR.png'
  conda: 'env/aPEAR.yml'
  script: 'R/aPEAR.R'

rule aPEAR_GSEA:
  input:
    gsea = 'output/enrichment/gsea',
    gmt = 'output/enrichment/gmt/human.gmt'
  output:
    aPEAR = 'output/figures/aPEARGSEA.png'
  conda: 'env/aPEAR.yml'
  script: 'R/aPEAR_GSEA.R'

rule emapplot:
  input:
    clusterProfiler = 'output/enrichment/clusterProfiler.RDS'
  output:
    emapplot = 'output/figures/emapplot.png'
  conda: 'env/aPEAR.yml'
  script: 'R/emapplot.R'

rule evaluateClustering:
  input:
    datasets = expand('data/dataset{id}.RDS', id = range(1, 21))
  output:
    eval = 'output/evaluation/clustering_{size}.RDS'
  threads: 5
  conda: 'env/aPEAR.yml'
  script: 'R/evaluateClustering.R'

rule generateEvalGraphs:
  input:
    eval = 'output/evaluation/clustering_{size}.RDS'
  output:
    csv = 'output/evaluation/clustering_{size}.csv',
    png = 'output/evaluation/clustering_{size}.png'
  conda: 'env/aPEAR.yml'
  script: 'R/generateEvalGraphs.R'
