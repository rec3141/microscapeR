# Internal (non-exported) helper functions

#' Bray-Curtis distance matrix
#' @param x Numeric matrix (rows = items, columns = features).
#' @return A \code{dist} object.
#' @keywords internal
.bray_curtis <- function(x) {
    n <- nrow(x)
    d <- matrix(0, n, n)
    for (i in seq_len(n - 1)) {
        if (i + 1L <= n) {
            for (j in seq.int(i + 1L, n)) {
                num   <- sum(abs(x[i, ] - x[j, ]))
                denom <- sum(x[i, ] + x[j, ])
                d[i, j] <- if (denom > 0) num / denom else 0
                d[j, i] <- d[i, j]
            }
        }
    }
    rownames(d) <- colnames(d) <- rownames(x)
    stats::as.dist(d)
}

#' Find sequences matching a taxonomy value at a given rank
#' @param taxa Character matrix of taxonomy assignments.
#' @param rank_name Character. Column name in \code{taxa}.
#' @param values Character vector. Values to match.
#' @return Character vector of matching row names.
#' @keywords internal
.find_at_rank <- function(taxa, rank_name, values) {
    if (!rank_name %in% colnames(taxa)) return(character(0))
    rownames(taxa)[taxa[, rank_name] %in% values &
                       !is.na(taxa[, rank_name])]
}
