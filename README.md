# aPEAR

This repository contains code used to perform analysis for the aPEAR paper.

## Requirements

- Snakemake
- Conda (optionally with mamba installed for faster environment creation)
- Cytoscape (must be running)
  - EnrichmentMap
  - AutoAnnotate

## How to run

In order to perform all analyses, run

```shell
snakemake --cores 1 --use-conda --conda-frontend mamba
```

## Comparison with Cytoscape

Comparison for Cytoscape is performed for 3 different datasets (code not provided).
The gene ranks are saved in the `data/geneRanks` directory. For each analysis,
minimal adjustments are made for the aPEAR as well as Cytoscape plots (described in
config file for aPEAR and `cytoscape` directory for Cytoscape).

## Quality and performance assessment

We have obtained 20 datasets containing various gene set enrichment results from previous analyses
we have performed (code not provided). In each dataset, we used 1000 most significant pathways (note
that this does not mean the pathways are in fact significant). For each gene set enrichment analysis,
we used either clusterProfiler or the GSEA software. The results  and the datasets can be found in
the `data` directory and are shortly described below:

1. `dataset1.RDS`: GSEA of RNAseq data of persons with Alzheimer's disease. Performed using clusterProfiler (GO).
2. `dataset2.RDS`: GSEA of RNAseq data of persons with Alzheimer's disease. Performed using the GSEA software.
3. `dataset3.RDS`: GSEA of RNAseq data of nasal swab from persons with Covid. Performed using clusterProfiler (GO).
4. `dataset4.RDS`: GSEA of RNAseq data of nasal swab from persons with Covid. Performed using the GSEA software.
5. `dataset5.RDS`: GSEA of EPIC data of persons with ovarian cancer. Performed using clusterProfiler (GO).
6. `dataset6.RDS`: GSEA of EPIC data of persons with ovarian cancer. Performed using the GSEA software.
7. `dataset7.RDS`: GSEA of EPIC data of persons who gave birth to newborns with FGR. Performed using clusterProfiler (GO).
8. `dataset8.RDS`: GSEA of EPIC data of persons who gave birth to newborns with FGR. Performed using the GSEA software.
9. `dataset9.RDS`: GSEA of EPIC data of persons with Alzheimer's disease. Performed using clusterProfiler (GO).
10. `dataset10.RDS`: GSEA of EPIC data of persons with Alzheimer's disease. Performed using the GSEA software.
11. `dataset11.RDS`: GSEA of EPIC data of persons with mild Alzheimer's disease. Performed using clusterProfiler (GO).
12. `dataset12.RDS`: GSEA of EPIC data of persons with mild Alzheimer's disease. Performed using the GSEA software.
13. `dataset13.RDS`: GSEA of WGBS data of persons with severe Covid. Performed using clusterProfiler (GO).
14. `dataset14.RDS`: GSEA of WGBS data of persons with severe Covid. Performed using the GSEA software.
15. `dataset15.RDS`: GSEA of EPIC data of persons who gave birth to newborns with autism spectrum disorder. Performed using clusterProfiler (GO).
16. `dataset16.RDS`: GSEA of EPIC data of persons who gave birth to newborns with autism spectrum disorder. Performed using the GSEA software.
17. `dataset17.RDS`: GSEA of RNAseq data of persons with late-stage Parkinson's disease. Performed using clusterProfiler (GO).
18. `dataset18.RDS`: GSEA of RNAseq data of persons with late-stage Parkinson's disease. Performed using the GSEA software.
19. `dataset19.RDS`: GSEA of deep RNAseq data of persons with Parkinson's disease. Performed using clusterProfiler (GO).
20. `dataset20.RDS`: GSEA of deep RNAseq data of persons with Parkinson's disease. Performed using the GSEA software.
