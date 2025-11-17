source("common.R")

cat("Step 7: Compute PCA Scores\n")

# Load PCA object from previous step dump
pca <- readRDS(file = "step-6.rds")
file.remove("step-6.rds")

# Compute PCA scores
pca_scores <- as.data.frame(pca$x)
pca_scores <- cbind(Sample = rownames(pca_scores), pca_scores)
rownames(pca_scores) <- NULL

write.table(pca_scores, outputFilePath, row.names = FALSE, quote = FALSE, sep = "\t")