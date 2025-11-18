library(minfi)
library("IlluminaHumanMethylationEPICmanifest", character.only = TRUE)
source("common.R")

cat("Step 1: Get B-values\n")

# Read options
options <- fromJSON(optionsFilePath)

# Read metadata
metadata <- read.table(file = inputFilePath, header = TRUE, sep = "\t", check.names = FALSE)

# Read IDATs
red_grn_set <- read.metharray(metadata$path, extended = TRUE, force = TRUE)

# Preprocess IDATs based on specified method
method = options$pp
if (method == "SWAN") {
  b_set <- preprocessSWAN(red_grn_set)
} else if (method == "Quantile") {
  b_set <- preprocessQuantile(red_grn_set)
} else if (method == "Noob") {
  b_set <- preprocessNoob(red_grn_set)
} else if (method == "Raw") {
  b_set <- preprocessRaw(red_grn_set)
} else {
  b_set <- preprocessIllumina(red_grn_set)
}

# Get B-values
b_values <- getBeta(b_set)

# Clean up
rm(red_grn_set)
rm(b_set)
gc()

# Dump step data
saveRDS(b_values, file = "step-1.rds")