source("common.R")

cat("Step 4: Filter B-values\n")

# Load transposed B-values from previous step dump
b_values_transposed <- readRDS(file = "step-3.rds")
file.remove("step-3.rds")

# Calculate variance for each probe
probe_variances <- apply(b_values_transposed, 2, var)

# Keep only probes with non-zero variance
b_values_filtered <- b_values_transposed[, probe_variances > 0]

# Clean up
rm(b_values_transposed)
rm(probe_variances)
gc()

# Dump step data
saveRDS(b_values_filtered, file = "step-4.rds")