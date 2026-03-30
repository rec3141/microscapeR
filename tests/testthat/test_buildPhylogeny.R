test_that("buildPhylogeny works with short sequences", {
    skip_if_not_installed("Biostrings")
    skip_if_not_installed("DECIPHER")

    seqs <- c(
        "ATGCATGCATGCATGCATGCATGCATGCATGCATGCATGCATGCATGCATGC",
        "ATGCATGCATGCATGCATGCATGCTTGCATGCATGCATGCATGCATGCATGC",
        "ATGCATGCATGCATGCATGCATGCATGCAAGCATGCATGCATGCATGCATGC",
        "ATGCATGCATGCATGCATGCATGCATGCATGCATGCATGCTTGCATGCATGC"
    )

    result <- buildPhylogeny(seqs, cpus = 1L)

    expect_type(result, "list")
    expect_named(result, c("tree", "distMatrix", "alignment"))
    expect_s3_class(result$tree, "phylo")
    expect_s3_class(result$distMatrix, "dist")
    expect_equal(ape::Ntip(result$tree), 4)
})

test_that("buildPhylogeny uses provided names as tip labels", {
    skip_if_not_installed("Biostrings")
    skip_if_not_installed("DECIPHER")

    seqs <- c(
        A = "ATGCATGCATGCATGCATGCATGCATGCATGCATGCATGCATGCATGCATGC",
        B = "ATGCATGCATGCATGCATGCATGCTTGCATGCATGCATGCATGCATGCATGC",
        C = "ATGCATGCATGCATGCATGCATGCATGCAAGCATGCATGCATGCATGCATGC",
        D = "ATGCATGCATGCATGCATGCATGCATGCATGCATGCATGCTTGCATGCATGC"
    )

    result <- buildPhylogeny(seqs, cpus = 1L)
    expect_true(all(c("A", "B", "C", "D") %in% result$tree$tip.label))
})

test_that("buildPhylogeny rejects too few sequences", {
    expect_error(buildPhylogeny(c("ATGC", "ATGC")),
                 "at least 3 entries")
})
