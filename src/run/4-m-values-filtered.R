source("common.R")

cat("Step 4: Filter M-values\n")

# Load transposed M-values from previous step dump
m_values_transposed <- readRDS(file = "step-3.rds")
file.remove("step-3.rds")

# Calculate variance for each probe
probe_variances <- apply(m_values_transposed, 2, var)

# Keep only probes with non-zero variance
m_values_filtered <- m_values_transposed[, probe_variances > 0]

# Clean up
rm(m_values_transposed)
rm(probe_variances)
gc()

# Dump step data
saveRDS(m_values_filtered, file = "step-4.rds")