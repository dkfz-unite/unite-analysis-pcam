library(minfi)
library("IlluminaHumanMethylationEPICmanifest", character.only = TRUE)

# Get B-values
# @param metadata A data frame containing the meta data, including the paths to the IDAT files.
# @param options A list containing options for preprocessing the IDAT files. The list should include:
# @return A matrix of B-values obtained after preprocessing the IDAT files.
get_b_values <- function(metadata, options) {
    # Read IDAT files
    red_grn_set <- read.metharray(metadata$path, extended = TRUE, force = TRUE)

    method = options$pp

    if (method == "preprocessSWAN") {
        b_set <- preprocessSWAN(red_grn_set)
    } else if (method == "preprocessQuantile") {
        b_set <- preprocessQuantile(red_grn_set)
    } else if (method == "preprocessNoob") {
        b_set <- preprocessNoob(red_grn_set)
    } else if (method == "preprocessRaw") {
        b_set <- preprocessRaw(red_grn_set)
    } else {
        b_set <- preprocessIllumina(red_grn_set)
    }

    b_values <- getBeta(b_set)
    rm(red_grn_set)
    rm(b_set)
    clean_memory()

    return(b_values)
}

clean_memory <- function() {
    gc(reset = TRUE, full = TRUE)
    gc(reset = TRUE, full = TRUE)
}
