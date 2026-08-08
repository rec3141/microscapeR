# Pipeline R engine scripts

These are the R implementations of the amplicon workflow as it ran in the
Nextflow pipeline (`--lang R`), preserved here when the pipeline consolidated
on a single Python engine and dropped its R pathway.

They are command-line scripts, not package API — each takes positional
arguments and writes files, and they are kept verbatim so the R pathway
remains reproducible. The equivalents exposed as package functions are
`autoTrim()`, `filterSeqtab()`, `loadMetadata()`, `renormalize()`,
`buildPhylogeny()`, `ordinateSamples()` and `sparccNetwork()`.

Run them with `Rscript`; each prints its usage when called with no arguments.
