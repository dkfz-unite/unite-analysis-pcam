library(jsonlite)
source("helper.R")
opts <- fromJSON(args[2])

args = commandArgs(trailingOnly = T)

metadata <- read.table(file = args[1], header = T, sep = "\t", check.names = F)

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

# Here we assume metadata$basename matches column names of b_values
metadata$basename <- basename(metadata$path)
rownames(betaVals_t_filtered) <- metadata$sample_id[match(rownames(betaVals_t_filtered), metadata$basename)]

# Run PCA
pca <- prcomp(betaVals_t_filtered, center = TRUE, scale. = TRUE)

#Add Column Names
pca_scores <- as.data.frame(pca$x)
pca_scores <- cbind(Sample = rownames(pca_scores), pca_scores)
rownames(pca_scores) <- NULL  # optional: remove row names to match first column

# Extract base folder from the first row of metadata$path
base_folder <- gsub("/Donor.*/.*", "/", metadata$path[1])

pca_with_group <- merge(
    pca_scores,
    metadata[, c("sample_id", "path", "conditions","age","sex")],
    by.x = "Sample",
    by.y = "sample_id",
    all.x = TRUE
)

# Save compressed pca results
get_compressed_result(pca_with_group, file.path(base_folder, "results.csv.gz"))