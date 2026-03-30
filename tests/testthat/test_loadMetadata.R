test_that("loadMetadata reads a CSV file correctly", {
    library(data.table)

    tmp <- tempfile(fileext = ".csv")
    on.exit(unlink(tmp))
    writeLines(c("sample_name,site,depth",
                 "S1,A,10",
                 "S2,B,20",
                 "S3,C,30"), tmp)

    meta <- loadMetadata(tmp)

    expect_s3_class(meta, "data.table")
    expect_equal(nrow(meta), 3)
    expect_true("sample_name" %in% colnames(meta))
    expect_true("site" %in% colnames(meta))
    expect_true("depth" %in% colnames(meta))
})

test_that("loadMetadata reads a TSV file correctly", {
    tmp <- tempfile(fileext = ".tsv")
    on.exit(unlink(tmp))
    writeLines(c("sample_name\tsite\tdepth",
                 "S1\tA\t10",
                 "S2\tB\t20"), tmp)

    meta <- loadMetadata(tmp)

    expect_s3_class(meta, "data.table")
    expect_equal(nrow(meta), 2)
})

test_that("loadMetadata matches to seqtab when provided", {
    library(data.table)

    tmp <- tempfile(fileext = ".csv")
    on.exit(unlink(tmp))
    writeLines(c("sample_name,site",
                 "S1,A",
                 "S2,B",
                 "S3,C"), tmp)

    seqtab <- data.table(sample = c("S1", "S2"), sequence = "X", count = 1)

    meta <- loadMetadata(tmp, seqtab = seqtab)
    expect_equal(nrow(meta), 2)
    expect_true(all(meta$sample_name %in% c("S1", "S2")))
})

test_that("loadMetadata errors on missing file", {
    expect_error(loadMetadata("/no/such/file.tsv"), "not found")
})
