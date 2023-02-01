
rule all:
  input:
    'output/enrichment/gsea'

rule gsea:
  input:
    gmt = 'output/temp/human.gmt',
    rank = 'output/temp/rank.rnk',
    soft = ancient('GSEA_4.3.2/gsea-cli.sh')
  output:
    gsea = 'output/enrichment/gsea'
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
  shell:
    """
      wget http://download.baderlab.org/EM_Genesets/January_01_2023/Human/entrezgene/Human_GOBP_AllPathways_no_GO_iea_January_01_2023_entrezgene.gmt -O {output.gmt}
    """
