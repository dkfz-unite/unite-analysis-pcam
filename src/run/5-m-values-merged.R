source("common.R")

cat("Step 5: Merge M-values with metadata\n")

# Load filtered M-values from previous step dump
m_values_filtered <- readRDS(file = "step-4.rds")
file.remove("step-4.rds")

# Read metadata
metadata <- read.table(file = inputFilePath, header = TRUE, sep = "\t", check.names = FALSE)

# Merge metadata with M-values
metadata$basename <- basename(metadata$path)
indices <- match(rownames(m_values_filtered), metadata$basename)
rownames(m_values_filtered) <- metadata$sample_id[indices]

# Clean up
rm(metadata)
rm(indices)
gc()

# Dump step data
saveRDS(m_values_filtered, file = "step-5.rds")