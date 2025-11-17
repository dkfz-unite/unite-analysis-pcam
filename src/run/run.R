source("common.R")

steps <- list(
  "1-b-values.R",
  "2-b-values-clean.R",
  "3-b-values-transposed.R",
  "4-b-values-filtered.R",
  "5-optional-step.R",
  "6-pca.R",
  "7pca-scores.R"
)

# Run each step sequentially in a separate R process with the arguments provided (args from common.R)
for (step in steps) {
    system2("Rscript", args = c(file.path("src", "run", step), args))
}