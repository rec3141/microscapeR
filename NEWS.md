Changes in version 0.99.1 (2026-08-08)
----------------------------------------

* DEPRECATED. This package is no longer maintained. The amplicon workflow
  it mirrored now lives in one place, as the `illumina_amplicon` stage of
  danaSeq (https://github.com/rec3141/danaSeq), which runs a single Python
  engine. This repository is archived as a reference snapshot.

* autoTrim(): recommend dada2 truncation lengths from paired-end quality
  profiles. Added so the R implementation of the amplicon workflow survives
  the consolidation. The quality position is floored at `min_length` and
  then capped at the 10th-percentile amplicon read length, so a floor above
  the library's real read length can never truncate every read out of
  existence -- the failure that returned 607 of 101194 reads on a 2x150
  library whose reads were 126 bp after primer removal.

* inst/scripts/: the pipeline's R engine scripts, preserved verbatim when
  the pipeline dropped its R pathway.

Changes in version 0.99.0 (2026-03-30)
----------------------------------------

* Initial Bioconductor submission.
* filterSeqtab(): cascade filtering of long-format sequence tables by
  length, prevalence, abundance, and sequencing depth.
* loadMetadata(): auto-detect MIMARKS metadata fields from TSV/CSV files
  and match to sequence table sample IDs.
* renormalize(): classify ASVs into taxonomic groups (prokaryote,
  chloroplast, mitochondria, eukaryote) and normalize counts within
  each group.
* buildPhylogeny(): multiple sequence alignment via DECIPHER and
  neighbor-joining tree construction with ape.
* ordinateSamples(): Bray-Curtis distance ordination using PCA followed
  by t-SNE embedding.
* sparccNetwork(): CLR-based compositional correlation network analysis
  returning an edge list.
