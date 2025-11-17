library(jsonlite)
source("helper.R")

args = commandArgs(trailingOnly = TRUE)

inputFilePath <- args[1]
outputFilePath <- args[3]
optionsFilePath <- args[2]

# Read options JSON
options <- fromJSON(optionsFilePath)

# Read metadata
metadata <- read.table(file = inputFilePath, header = TRUE, sep = "\t", check.names = FALSE)

# Generate beta values
b_values = get_b_values(metadata, options)

# Clean beta values
b_values_clean <- b_values[complete.cases(b_values), ]
rm(b_values)
clean_memory()

# Transpose beta values so that rows = samples, columns = probes
b_values_transposed <- t(b_values_clean)
rm(b_values_clean)
clean_memory()

# Cannot rescale a constant/zero column to unit variance
# Calculate variance for each probe (i.e., each column)
probe_variances <- apply(b_values_transposed, 2, var)

# Keep only columns (probes) with non-zero variance
b_values_filtered <- b_values_transposed[, probe_variances > 0]
rm(b_values_transposed)
rm(probe_variances)
clean_memory()

# Here we assume metadata$basename matches column names of b_values
metadata$basename <- basename(metadata$path)
rownames(b_values_filtered) <- metadata$sample_id[match(rownames(b_values_filtered), metadata$basename)]

# Run PCA
pca <- prcomp(b_values_filtered, center = TRUE, scale. = TRUE)
rm(b_values_filtered)
clean_memory()

# Add column names
pca_scores <- as.data.frame(pca$x)
pca_scores <- cbind(Sample = rownames(pca_scores), pca_scores)
rownames(pca_scores) <- NULL

write.table(pca_scores, outputFilePath, row.names = FALSE, quote = FALSE, sep = "\t")
clean_memory()
