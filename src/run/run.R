source("common.R")

steps <- list(
  "1-b-values.R",
  "2-b-values-clean.R",
  "3-b-values-transposed.R",
  "4-b-values-filtered.R",
  "5-b-values-merged.R",
  "6-pca.R",
  "7-pca-scores.R"
)

# Run each step sequentially
for (step in steps) {
  system2("Rscript", args = c(step, args))
}