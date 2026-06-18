source("common.R")

cat("Step 2: Clean M-values\n")

# Load M-values from previous step dump
m_values <- readRDS(file = "step-1.rds")
file.remove("step-1.rds")

# Clean M-values
m_values_clean <- m_values[complete.cases(m_values), ]

# Clean up
rm(m_values)
gc()

# Dump step data
saveRDS(m_values_clean, file = "step-2.rds")