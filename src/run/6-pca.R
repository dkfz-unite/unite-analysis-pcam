source("common.R")

cat("Step 6: Perform PCA\n")

# Load filtered B-values from previous step dump
b_values_filtered <- readRDS(file = "step-5.rds")
file.remove("step-5.rds")

# Determine number of components to compute (max 20 or number of samples)
components_number <- min(20L, nrow(b_values_filtered), ncol(b_values_filtered))

# Perform PCA
set.seed(123)
# pca <- prcomp(b_values_filtered, center = TRUE, scale. = TRUE)
pca <- irlba::prcomp_irlba(
  b_values_filtered,
  n = as.integer(components_number),
  center = TRUE,
  scale. = TRUE
)

# Remove rotation matrix to save space
# pca$rotation <- NULL

# Clean up
rm(b_values_filtered)
gc()

# Dump step data
saveRDS(pca, file = "step-6.rds")