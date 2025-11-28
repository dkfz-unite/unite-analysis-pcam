library(minfi)
source("common.R")

cat("Step 1: Get B-values\n")

preprocess_group <- function(files, method) {
  red_grn_set <- read.metharray(files, extended = TRUE, force = TRUE)

  if (method == "SWAN") {
    b_set <- preprocessSWAN(red_grn_set)
  } else if (method == "Quantile") {
    b_set <- preprocessQuantile(red_grn_set)
  } else if (method == "Noob") {
    b_set <- preprocessNoob(red_grn_set)
  } else if (method == "Raw") {
    b_set <- preprocessRaw(red_grn_set)
  } else {
    b_set <- preprocessIllumina(red_grn_set)
  }

  rm(red_grn_set); gc()
  getBeta(b_set)
}

# Read options
options <- fromJSON(optionsFilePath)

# Read metadata
metadata <- read.table(file = inputFilePath, header = TRUE, sep = "\t", check.names = FALSE)
files = metadata$path

# Detect array types
array_types <- sapply(files, function(f) { minfi::guessArrayType(f) })
df <- data.frame(file = files, array = array_types, stringsAsFactors = FALSE)

# Group by arrays type
groups <- split(df$file, df$array)

# Preprocess each group separately
group_betas <- list()
for (grp in names(groups)) {
  group_betas[[grp]] <- preprocess_group(groups[[grp]], options$pp)
}

# Find common probes
common_probes <- Reduce(intersect, lapply(group_betas, rownames))

# Merge B-values from all groups based on common probes
merged <- do.call(cbind, lapply(group_betas, function(b) b[common_probes, , drop = FALSE]))

# Dump step data
saveRDS(merged, file = "step-1.rds")

# Clean up
rm(df);
rm(group_betas);
rm(merged);
gc()
