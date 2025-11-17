source("common.R")

cat("Step 6: Perform PCA\n")

# Load filtered B-values from previous step dump
b_values_filtered <- readRDS(file = "step-5.rds")
file.remove("step-5.rds")

# Perform PCA
pca <- prcomp(b_values_filtered, center = TRUE, scale. = TRUE)

# Dump PCA object
saveRDS(pca, file = "step-6.rds")