library(minfi)
args = commandArgs(trailingOnly = T)
analysis_package <- "IlluminaHumanMethylationEPICmanifest"
library(analysis_package, character.only = TRUE)


# Get B-values
# @param metadata A data frame containing the meta data, including the paths to the IDAT files.
# @param opts A list containing options for preprocessing the IDAT files. The list should include:
# @return A matrix of B-values obtained after preprocessing the IDAT files.
get_b_values <- function(metadata, opts) {
    # Read IDAT files
    RGset <- read.metharray(metadata$path, extended = TRUE, force = TRUE)

    preprocess_method = opts$pp
    if (preprocess_method == "preprocessSWAN") {
        betaSet <- preprocessSWAN(RGset)
    } else if (preprocess_method == "preprocessQuantile") {
        betaSet <- preprocessQuantile(RGset)
    } else if (preprocess_method == "preprocessNoob") {
        betaSet <- preprocessNoob(RGset)
    } else if (preprocess_method == "preprocessRaw") {
        betaSet <- preprocessRaw(RGset)
    } else {
        betaSet <- preprocessIllumina(RGset)
    }
    # get m_ values
    b_values <- getBeta(betaSet)
    return(b_values)
}