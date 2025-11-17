source("common.R")

cat("Step 3: Transpose B-values\n")

# Load cleaned B-values from previous step dump
b_values_clean <- readRDS(file = "step-2.rds")
file.remove("step-2.rds")

# Transpose B-values so that rows = samples, columns = probes
b_values_transposed <- t(b_values_clean)

# Dump step data
saveRDS(b_values_transposed, file = "step-3.rds")