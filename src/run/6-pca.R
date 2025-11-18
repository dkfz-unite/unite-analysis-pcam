source("common.R")

cat("Step 6: Perform PCA\n")

# Load filtered B-values from previous step dump
b_values_filtered <- readRDS(file = "step-5.rds")
file.remove("step-5.rds")

# Perform PCA
set.seed(123)
rank = min(20, ncol(b_values_filtered) - 1, nrow(b_values_filtered) - 1)
pca <- prcomp(b_values_filtered, center = TRUE, scale. = TRUE, rank. = rank)

# Remove rotation matrix to save space
pca$rotation <- NULL

# Clean up
rm(b_values_filtered)
gc()

# Dump step data
saveRDS(pca, file = "step-6.rds")