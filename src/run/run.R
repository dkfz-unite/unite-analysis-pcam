source("/src/common.R")

steps <- list(
  "/src/1-b-values.R",
  "/src/2-b-values-clean.R",
  "/src/3-b-values-transposed.R",
  "/src/4-b-values-filtered.R",
  "/src/5-b-values-merged.R",
  "/src/6-pca.R",
  "/src/7-pca-scores.R"
)

# Run each step sequentially
for (step in steps) {
    system2("Rscript", args = c(step, args))
}
