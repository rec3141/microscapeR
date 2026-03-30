test_that("sparccNetwork returns correct edge list structure", {
    library(data.table)

    dt <- data.table(
        sample   = rep(paste0("S", 1:10), each = 5),
        sequence = rep(paste0("seq", 1:5), 10),
        count    = rep(c(100, 80, 60, 40, 20), 10)
    )

    edges <- sparccNetwork(dt, minPrevalence = 0.1, minCorrelation = 0.01)

    expect_s3_class(edges, "data.table")
    expect_true(all(c("node1", "node2", "correlation", "weight", "color") %in%
                        colnames(edges)))

    ## All colors should be "blue" or "red"
    expect_true(all(edges$color %in% c("blue", "red")))

    ## Weights should be in [0, 1]
    expect_true(all(edges$weight >= 0 & edges$weight <= 1))
})

test_that("sparccNetwork rejects non-data.table", {
    expect_error(sparccNetwork(data.frame(x = 1)),
                 "must be a data.table")
})

test_that("sparccNetwork errors with too few ASVs", {
    library(data.table)
    dt <- data.table(
        sample = c("S1", "S2"),
        sequence = c("seq1", "seq1"),
        count = c(10, 20)
    )
    expect_error(sparccNetwork(dt, minPrevalence = 0.1), "Too few ASVs")
})
