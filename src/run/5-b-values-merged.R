source("common.R")

cat("Step 5: Merge B-values with metadata\n")

# Load filtered B-values from previous step dump
b_values_filtered <- readRDS(file = "step-4.rds")
file.remove("step-4.rds")

# Read metadata
metadata <- read.table(file = inputFilePath, header = TRUE, sep = "\t", check.names = FALSE)

# Merge metadata with B-values
metadata$basename <- basename(metadata$path)
indices <- match(rownames(b_values_filtered), metadata$basename)
rownames(b_values_filtered) <- metadata$sample_id[indices]

# Dump data
saveRDS(b_values_filtered, file = "step-5.rds")