source("common.R")

steps <- list(
  "1-m-values.R",
  "2-m-values-clean.R",
  "3-m-values-transposed.R",
  "4-m-values-filtered.R",
  "5-m-values-merged.R",
  "6-pca.R",
  "7-pca-scores.R"
)

# Run each step sequentially
for (step in steps) {
  system2("Rscript", args = c(step, args))
}