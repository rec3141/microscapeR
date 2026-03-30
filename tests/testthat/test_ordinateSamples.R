test_that("ordinateSamples PCA returns correct structure", {
    library(data.table)

    dt <- data.table(
        sample   = rep(paste0("S", 1:5), each = 4),
        sequence = rep(paste0("seq", 1:4), 5),
        count    = c(100, 50, 30, 10,
                     80, 40, 20, 8,
                     120, 60, 35, 12,
                     90, 45, 25, 11,
                     110, 55, 32, 9)
    )

    res <- ordinateSamples(dt, method = "pca", metric = "bray")

    expect_type(res, "list")
    expect_named(res, c("sampleCoords", "asvCoords", "distances"))

    ## sampleCoords
    expect_s3_class(res$sampleCoords, "data.frame")
    expect_true(all(c("label", "Axis1", "Axis2") %in%
                        colnames(res$sampleCoords)))
    expect_equal(nrow(res$sampleCoords), 5)

    ## asvCoords
    expect_s3_class(res$asvCoords, "data.frame")
    expect_equal(nrow(res$asvCoords), 4)

    ## distances
    expect_type(res$distances, "list")
    expect_s3_class(res$distances$samples, "dist")
    expect_s3_class(res$distances$asvs, "dist")
})

test_that("ordinateSamples rejects non-data.table", {
    expect_error(ordinateSamples(data.frame(x = 1)),
                 "must be a data.table")
})

test_that("ordinateSamples euclidean metric works", {
    library(data.table)

    dt <- data.table(
        sample   = rep(paste0("S", 1:4), each = 3),
        sequence = rep(paste0("seq", 1:3), 4),
        count    = c(10, 20, 30, 40, 50, 60, 70, 80, 90, 15, 25, 35)
    )

    res <- ordinateSamples(dt, method = "pca", metric = "euclidean")
    expect_s3_class(res$sampleCoords, "data.frame")
})
