# microscapeR

**Downstream analysis tools for amplicon sequencing data**

[![R CMD check](https://img.shields.io/badge/R%20CMD%20check-OK-brightgreen)](https://github.com/rec3141/microscapeR)
[![License: BSD-3-Clause](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](LICENSE)

`microscapeR` provides downstream analysis tools for amplicon sequencing data produced by [DADA2](https://benjjneb.github.io/dada2/). It is the R companion to the Python [microscape](https://github.com/rec3141/microscape) package, with matching functionality in both languages.

## Installation

```r
# From Bioconductor (once accepted)
BiocManager::install("microscapeR")

# Development version from GitHub
BiocManager::install("rec3141/microscapeR")
```

## Functions

| Function | Description |
|---|---|
| `filterSeqtab()` | Cascade QC filtering: length, prevalence, abundance, depth |
| `loadMetadata()` | Load MIMARKS-compliant sample metadata |
| `renormalize()` | Group ASVs by taxonomy and compute within-group proportions |
| `buildPhylogeny()` | Multiple sequence alignment (DECIPHER) + neighbor-joining tree |
| `ordinateSamples()` | Bray-Curtis distances with PCA or t-SNE ordination |
| `sparccNetwork()` | CLR-transformed correlation network (SparCC approximation) |

## Quick Example

```r
library(microscapeR)
library(dada2)

# After running the standard dada2 pipeline...
# seqtab_nochim <- removeBimeraDenovo(seqtab)

# Filter the sequence table
result <- filterSeqtab(seqtab_long,
                       minLength = 50,
                       minSamples = 2,
                       minSeqs = 3,
                       minReads = 100)

# Build phylogeny
phylo <- buildPhylogeny(unique(result$filtered$sequence))

# Ordinate samples
ord <- ordinateSamples(result$filtered, method = "tsne")

# Correlation network
edges <- sparccNetwork(result$filtered, minPrevalence = 0.1)
```

## Related Packages

- **[dada2](https://benjjneb.github.io/dada2/)** — Core amplicon denoising (Bioconductor)
- **[papa2](https://github.com/rec3141/papa2)** — Python port of dada2 (bioconda)
- **[microscape](https://github.com/rec3141/microscape)** — Python version of this package (bioconda)

## Citation

If you use microscapeR, please cite DADA2:

> Callahan BJ, McMurdie PJ, Rosen MJ, Han AW, Johnson AJA, Holmes SP (2016).
> DADA2: High-resolution sample inference from Illumina amplicon data.
> *Nature Methods*, 13, 581-583.
