#' @importFrom stats median quantile
#'
#' @title Recommend Truncation Lengths from Quality Profiles
#'
#' @description Profiles paired-end FASTQ files and recommends the truncation
#'   lengths to pass to \code{dada2::filterAndTrim()}. The recommendation is
#'   the position where a rolling median quality falls below \code{min_quality},
#'   floored at \code{min_length}, and then capped at the 10th-percentile read
#'   length so the truncation never asks for bases the reads do not carry.
#'
#'   The cap matters more than it looks. DADA2 discards any read shorter than
#'   \code{truncLen}, so a floor applied above the library's real read length
#'   silently returns zero reads for every sample: a 2x150 run whose amplicon
#'   reads are 126 bp after primer removal, profiled against a 150 bp floor,
#'   keeps 607 of 101194 reads. The floor belongs on the quality position --
#'   where it stops a quality dip truncating below the overlap that
#'   \code{mergePairs()} needs -- and never on the length cap.
#'
#'   The percentile is measured over amplicon-length reads only. Adapter-dimer
#'   and primer-only fragments form a second mode an order of magnitude
#'   shorter than the product, and once they exceed 10% of the library a low
#'   percentile falls inside that mode and truncates the real reads into
#'   oblivion. Reads shorter than half the median are dropped before measuring,
#'   unless nearly all of them are (a broken library rather than a bimodal one,
#'   where measuring the remainder would be less honest than measuring all).
#'
#' @param input_dir Directory containing paired FASTQ files. Forward reads are
#'   matched as \code{*_1.fastq.gz}, \code{*_R1*.fastq.gz} or
#'   \code{*_R1.*.fastq.gz}; reverse reads with the matching \code{2}/\code{R2}
#'   patterns.
#' @param min_quality Minimum rolling median Phred score to keep a position.
#' @param window Rolling window width, in positions, for quality smoothing.
#' @param n_reads Number of reads to sample across files.
#' @param n_files Maximum number of file pairs to sample from.
#' @param min_length Floor for the quality-driven position. Never raises the
#'   truncation above the reads that exist.
#'
#' @return A named list with \code{trunc_len_fwd}, \code{trunc_len_rev},
#'   \code{fwd_read_len}, \code{rev_read_len}, \code{n_reads_sampled},
#'   \code{min_quality} and \code{min_length}.
#'
#' @export
#'
#' @examples
#' # Point at a directory of paired FASTQs:
#' \donttest{
#' fq <- system.file("extdata", package = "microscapeR")
#' if (length(Sys.glob(file.path(fq, "*_1.fastq.gz")))) {
#'     autoTrim(fq, min_quality = 25, min_length = 150)
#' }
#' }
autoTrim <- function(input_dir, min_quality = 25, window = 10L,
                     n_reads = 10000L, n_files = 20L, min_length = 0L) {
    stopifnot(dir.exists(input_dir))
    window <- as.integer(window)
    n_reads <- as.integer(n_reads)
    n_files <- as.integer(n_files)
    min_length <- as.integer(min_length)

    fwd_files <- .glob_mates(input_dir,
                             c("*_1.fastq.gz", "*_R1*.fastq.gz", "*_R1.*.fastq.gz"))
    rev_files <- .glob_mates(input_dir,
                             c("*_2.fastq.gz", "*_R2*.fastq.gz", "*_R2.*.fastq.gz"))
    if (!length(fwd_files) || !length(rev_files)) {
        stop("No paired FASTQ files found in ", input_dir)
    }

    fwd_quals <- .read_quals(.subsample_files(fwd_files, n_files), n_reads)
    rev_quals <- .read_quals(.subsample_files(rev_files, n_files), n_reads)

    list(
        trunc_len_fwd   = .find_trunc_pos(fwd_quals, min_quality, window, min_length),
        trunc_len_rev   = .find_trunc_pos(rev_quals, min_quality, window, min_length),
        fwd_read_len    = if (length(fwd_quals))
            max(vapply(fwd_quals, length, integer(1))) else 0L,
        rev_read_len    = if (length(rev_quals))
            max(vapply(rev_quals, length, integer(1))) else 0L,
        n_reads_sampled = length(fwd_quals),
        min_quality     = min_quality,
        min_length      = min_length
    )
}


.glob_mates <- function(dir, pats) {
    sort(unique(unlist(lapply(pats, function(p) Sys.glob(file.path(dir, p))))))
}


.subsample_files <- function(files, n_files) {
    n_sample <- min(n_files, length(files))
    step <- max(1L, length(files) %/% n_sample)
    strided <- files[seq(1L, length(files), by = step)]
    strided[seq_len(min(n_sample, length(strided)))]
}


.read_quals <- function(files, n_reads) {
    out <- vector("list", n_reads)
    count <- 0L
    for (fpath in files) {
        con <- if (grepl("\\.gz$", fpath)) gzfile(fpath, "rt") else file(fpath, "rt")
        repeat {
            if (count >= n_reads) break
            rec <- readLines(con, n = 4L, warn = FALSE)
            if (length(rec) < 4L) break
            qual_str <- sub("\\s+$", "", rec[4])
            if (!nzchar(qual_str)) break
            count <- count + 1L
            out[[count]] <- utf8ToInt(qual_str) - 33L
        }
        close(con)
        if (count >= n_reads) break
    }
    if (count == 0L) list() else out[seq_len(count)]
}


.amplicon_lengths <- function(lengths, floor_frac = 0.5) {
    if (!length(lengths)) return(lengths)
    med <- as.numeric(stats::median(lengths))
    usable <- lengths[lengths >= med * floor_frac]
    if (length(usable) >= max(10, 0.05 * length(lengths))) usable else lengths
}


.find_trunc_pos <- function(quals_list, min_q, window, min_length = 0L) {
    if (!length(quals_list)) return(0L)
    lengths <- vapply(quals_list, length, integer(1))
    max_len <- max(lengths)

    len_cap <- min(as.integer(stats::quantile(.amplicon_lengths(lengths), 0.10,
                                              type = 7, names = FALSE)),
                   max_len)

    mat <- matrix(NA_integer_, nrow = length(quals_list), ncol = max_len)
    for (i in seq_along(quals_list)) {
        q <- quals_list[[i]]
        mat[i, seq_along(q)] <- q
    }
    medians <- apply(mat, 2L, stats::median, na.rm = TRUE)

    n <- length(medians)
    if (n < window) return(min(max(as.integer(n), min_length), len_cap))

    cs <- cumsum(c(0, medians))
    rolling <- (cs[(window + 1L):(n + 1L)] - cs[1L:(n - window + 1L)]) / window

    quality_pos <- as.integer(n)
    below <- which(rolling < min_q)
    if (length(below)) {
        quality_pos <- as.integer((below[1L] - 1L) + window %/% 2L)
    }

    min(max(quality_pos, min_length), len_cap)
}
