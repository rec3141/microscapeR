# Suppress R CMD check NOTEs for data.table non-standard evaluation
utils::globalVariables(c(
    ".", "N", "len", "n_samples", "count", "total", "group",
    "total_in_group", "proportion", "prevalence", "sample", "sequence",
    "node1", "node2", "correlation", "weight", "color"
))
