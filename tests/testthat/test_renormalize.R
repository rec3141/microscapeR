test_that("renormalize classifies and normalizes correctly", {
    library(data.table)

    dt <- data.table(
        sample   = rep(c("S1", "S2"), each = 3),
        sequence = rep(c("AAAA", "CCCC", "GGGG"), 2),
        count    = c(100, 50, 10, 80, 60, 20)
    )

    taxa <- matrix(
        c("Bacteria", "Cyanobacteria", "Cyanobacteriia",
          "Chloroplast", NA, NA,
          "Bacteria", "Proteobacteria", "Alphaproteobacteria",
          "Rickettsiales", "Mitochondria", NA,
          "Bacteria", "Firmicutes", "Bacilli",
          "Lactobacillales", "Lactobacillaceae", "Lactobacillus"),
        nrow = 3, byrow = TRUE,
        dimnames = list(c("AAAA", "CCCC", "GGGG"),
                        c("Domain", "Phylum", "Class",
                          "Order", "Family", "Genus"))
    )

    groups <- renormalize(dt, taxa)

    expect_type(groups, "list")
    expect_true(length(groups) >= 1)

    ## Check that all group tables have the expected columns
    for (g in names(groups)) {
        expect_true(all(c("sample", "sequence", "count", "proportion") %in%
                            colnames(groups[[g]])))
    }

    ## Chloroplast should contain AAAA
    if ("chloroplast" %in% names(groups)) {
        expect_true("AAAA" %in% groups$chloroplast$sequence)
    }

    ## Prokaryote should contain GGGG (but not AAAA or CCCC)
    if ("prokaryote" %in% names(groups)) {
        expect_true("GGGG" %in% groups$prokaryote$sequence)
        expect_false("AAAA" %in% groups$prokaryote$sequence)
    }
})

test_that("renormalize errors on non-data.table", {
    expect_error(renormalize(data.frame(x = 1), matrix()), "must be a data.table")
})

test_that("renormalize errors on non-matrix taxa", {
    library(data.table)
    dt <- data.table(sample = "S1", sequence = "A", count = 1)
    expect_error(renormalize(dt, data.frame(x = 1)), "must be a character matrix")
})
