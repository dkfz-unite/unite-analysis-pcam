source("common.R")

cat("Step 2: Clean B-values\n")

# Load B-values from previous step dump
b_values <- readRDS(file = "step-1.rds")
file.remove("step-1.rds")

# Clean B-values
b_values_clean <- b_values[complete.cases(b_values), ]

# Dump step data
saveRDS(b_values_clean, file = "step-2.rds")