
configfile: 'config.yml'

rule all:
  input:
    emapplot = 'output/figures/emapplot.png',
    aPEAR = 'output/figures/aPEAR.png',
    aPEAR_tiff = 'output/figures/aPEAR.tiff',
    aPEAR_GSEA = expand('output/figures/aPEAR_GSEA_{dataset}.png', dataset = ['dataset1', 'dataset2', 'dataset3']),
    cytoscape = expand('output/figures/cytoscape_{dataset}.png', dataset = ['dataset1', 'dataset2', 'dataset3']),
    csv = 'output/evaluation/clustering_100.csv',
    clusterQuality = 'output/evaluation/clustering_100.png'

rule gsea:
  input:
    gmt = 'output/enrichment/gmt/human.gmt',
    rank = ancient('data/geneRanks/{dataset}.rnk'),
    soft = ancient('GSEA_4.3.2/gsea-cli.sh')
  output:
    gsea = directory('output/enrichment/gsea/{dataset}')
  log:
    log = 'logs/gsea_{dataset}.log'
  conda: 'env/aPEAR.yml'
  script: 'R/gsea.R'

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
#            Cannot be executed parallely for different wildcards.
#
rule cytoscape:
  input:
    gsea = 'output/enrichment/gsea/{dataset}',
    gmt = 'output/enrichment/gmt/human.gmt',
    filter = ancient('cytoscape/filter_{dataset}.json')
  output:
    image = 'output/figures/cytoscape_{dataset}.png'
  conda: 'env/aPEAR.yml'
  threads: 4
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
    aPEAR = 'output/figures/aPEAR.png',
    tiff = 'output/figures/aPEAR.tiff'
  conda: 'env/aPEAR.yml'
  script: 'R/aPEAR.R'

rule aPEAR_GSEA:
  input:
    gsea = 'output/enrichment/gsea/{dataset}',
    gmt = 'output/enrichment/gmt/human.gmt'
  output:
    aPEAR = 'output/figures/aPEAR_GSEA_{dataset}.png'
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
