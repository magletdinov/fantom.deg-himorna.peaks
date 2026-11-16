#!/usr/bin/env Rscript

# --- Загрузка библиотек ---
suppressMessages({
  library(BSgenome.Hsapiens.UCSC.hg38)
  library(regioneR)
  library(GenomicRanges)
  library(rtracklayer)
  library(tools)  # для file_path_sans_ext
})

# --- Парсинг аргументов ---
args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 3) {
  stop("Usage: run_perm_test.R <path_to_A.bed> <path_to_B.bed> <mc.cores>")
}

bed_path_A <- args[1]
bed_path_B <- args[2]
mc_cores <- as.integer(args[3])

# --- Пути и имена файлов ---
output_dir <- "/export/home/agletdinov/work/git_projects/fantom.deg-himorna.peaks/preprocessing/permutation_res/"
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

# Получаем базовые имена файлов без расширения
name_A <- file_path_sans_ext(basename(bed_path_A))
name_B <- file_path_sans_ext(basename(bed_path_B))
output_base <- paste0(name_A, "__vs__", name_B)

# --- Импорт BED-файлов ---
cat("Загружаем набор A из:", bed_path_A, "\n")
A <- import(bed_path_A, format = "BED")

cat("Загружаем набор B из:", bed_path_B, "\n")
B <- import(bed_path_B, format = "BED")

# --- Пермутационный тест ---
set.seed(42)
cat("Выполняем permTest() с", mc_cores, "потоками...\n")

res <- permTest(
  A = A,
  B = B,
  ntimes = 100,
  randomize.function = randomizeRegions,
  evaluate.function = numOverlaps,
  genome = BSgenome.Hsapiens.UCSC.hg38,
  mc.cores = mc_cores
)

# --- Сохраняем результат ---
summary_txt_path <- file.path(output_dir, paste0(output_base, ".summary.txt"))
rds_path <- file.path(output_dir, paste0(output_base, ".RDS"))

cat("\nСохраняем summary в:", summary_txt_path, "\n")
write.table(
  summary(res),
  file = summary_txt_path,
  sep = "\t",
  quote = FALSE,
  col.names = NA
)

#cat("Сохраняем полный объект res в:", rds_path, "\n")
#saveRDS(res, file = rds_path)

cat("Готово.\n")
