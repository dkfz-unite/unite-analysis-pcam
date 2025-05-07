library(jsonlite)
source("helper.R")
opts <- fromJSON(args[2])

args = commandArgs(trailingOnly = T)

metadata <- read.table(file = args[1], header = T, sep = "\t", check.names = F)

# Convert 'Group' to factor with automatically generated levels
metadata = get_updated_metadata(metadata)

# generate beta values
b_values = get_b_values(metadata, opts)

# 1. Remove probes (rows) with any NA values
betaVals_clean <- b_values[complete.cases(b_values), ]

# 2. Transpose so rows = samples, columns = probes. We want to run analysis based on samples
betaVals_t <- t(betaVals_clean)

# 3.  Cannot rescale a constant/zero column to unit variance
# Calculate variance for each probe (i.e., each column)
probe_vars <- apply(betaVals_t, 2, var)

# 4. Keep only columns (probes) with non-zero variance
betaVals_t_filtered <- betaVals_t[, probe_vars > 0]

# Run PCA
pca <- prcomp(betaVals_t_filtered, center = TRUE, scale. = TRUE)

# Save compressed pca results
get_compressed_result(pca$x, file.path(base_folder, "results.csv.gz"))