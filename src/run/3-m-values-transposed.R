source("common.R")

cat("Step 3: Transpose M-values\n")

# Load cleaned M-values from previous step dump
m_values_clean <- readRDS(file = "step-2.rds")
file.remove("step-2.rds")

# Transpose M-values so that rows = samples, columns = probes
m_values_transposed <- t(m_values_clean)

# Clean up
rm(m_values_clean)
gc()

# Dump step data
saveRDS(m_values_transposed, file = "step-3.rds")