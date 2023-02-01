# pathExplore

This repository contains code used to perform analysis for the pathExplore paper.

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
