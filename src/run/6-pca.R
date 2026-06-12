source("common.R")

cat("Step 6: Perform PCA\n")

# Load filtered M-values from previous step dump
m_values_filtered <- readRDS(file = "step-5.rds")
file.remove("step-5.rds")

# Perform PCA
set.seed(123)
rank = min(20, ncol(m_values_filtered) - 1, nrow(m_values_filtered) - 1)
pca <- prcomp(m_values_filtered, center = TRUE, scale. = TRUE, rank. = rank)

# Remove rotation matrix to save space
pca$rotation <- NULL

# Clean up
rm(m_values_filtered)
gc()

# Dump step data
saveRDS(pca, file = "step-6.rds")