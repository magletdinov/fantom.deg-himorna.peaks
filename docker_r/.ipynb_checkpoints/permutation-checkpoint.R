#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(GenometriCorr)
  library(GenomicRanges)
  library(rtracklayer)
})

args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 2) {
  stop("Укажите два пути к BED-файлам как аргументы командной строки.")
}

bed1_path <- args[1]
bed2_path <- args[2]

cat("Загружаю BED-файлы:\n")
cat("  A: ", bed1_path, "\n")
cat("  B: ", bed2_path, "\n")

gr1 <- import(bed1_path, format = "BED")
gr2 <- import(bed2_path, format = "BED")

seqlevelsStyle(gr1) <- "UCSC"
seqlevelsStyle(gr2) <- "UCSC"

set.seed(42)
res <- GenometriCorrelation(
  A = gr1,
  B = gr2,
  B.name = "setB",
  only.index = FALSE,
  do.plot = FALSE,
  ntimes = 1000
)

# Сохраняем результат
out_file <- paste0(
  tools::file_path_sans_ext(basename(bed1_path)),
  "_vs_",
  tools::file_path_sans_ext(basename(bed2_path)),
  "_genometricorr.rds"
)

saveRDS(res, file = out_file)
cat("Результат сохранён в", out_file, "\n")