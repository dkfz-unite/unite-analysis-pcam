# PCA Service for Methylation Data

Shared architecture, development workflows, and agent instructions:
[UNITE project documentation](https://github.com/dkfz-unite/.github/blob/main/README.md).

## General
Principal component analysis (PCA) of Illumina methylation array data with [minfi](https://bioconductor.org/packages/minfi), wrapped with web API.

The R scripts ([src/run](src/run)) are run by the [commands](https://github.com/dkfz-unite/unite-commands) web service, which runs a configured command for each request. The service is used by the [analysis service](https://github.com/dkfz-unite/unite-analysis) for [PCAM analysis](https://github.com/dkfz-unite/unite-analysis/blob/main/Docs/api-analysis-pcam.md): the analysis service downloads the IDAT files and writes the input files to the shared analysis data directory, and calls the service with the analysis id as process key.

[run.R](src/run/run.R) runs the steps below one after another, each as a separate `Rscript` process (to release memory between steps). Intermediate results are saved as `step-{n}.rds` files in the working directory of the command (`/src`) and deleted by the next step.
1. [1-m-values.R](src/run/1-m-values.R) - reads the IDAT files of the samples (`read.metharray`), preprocesses them with the selected minfi method and calculates M-values (`getM`).
2. [2-m-values-clean.R](src/run/2-m-values-clean.R) - removes probes with missing values.
3. [3-m-values-transposed.R](src/run/3-m-values-transposed.R) - transposes the matrix (rows are samples).
4. [4-m-values-filtered.R](src/run/4-m-values-filtered.R) - removes probes with zero variance.
5. [5-m-values-merged.R](src/run/5-m-values-merged.R) - replaces IDAT names with sample ids from the metadata.
6. [6-pca.R](src/run/6-pca.R) - runs `prcomp` (centered, scaled) with up to 20 components (fewer if there are fewer samples or probes).
7. [7-pca-scores.R](src/run/7-pca-scores.R) - writes the PCA scores.

`run.R` does not check the exit codes of the steps: if a step fails, the following steps fail as well and the result file is not written, but `run.R` itself may still finish successfully.

The scripts use the `IlluminaHumanMethylationEPICmanifest` manifest. R packages: `minfi`, `jsonlite` and the EPIC manifest package, expected from the base image `ghcr.io/dkfz-unite/docker-rdev-minfi` ([src/install/install.R](src/install/install.R) is empty).

## Configuration
To configure the application, change environment variables as required in [commands](https://github.com/dkfz-unite/unite-commands/blob/main/README.md#configuration) web service. The [Dockerfile](Dockerfile) sets the following values:
- `UNITE_COMMAND` - command to run the analysis script (`Rscript`).
- `UNITE_COMMAND_ARGUMENTS` - command arguments (`run.R {data}/{proc}/metadata.tsv {data}/{proc}/options.json {data}/{proc}/results.tsv`).
  - `{data}` is replaced with `UNITE_DATA_PATH`, `{proc}` with the process key (analysis id).
- `UNITE_SOURCE_PATH` - location of the scripts in docker container, the working directory of the command (`/src`).
- `UNITE_DATA_PATH` - location of the data in docker container (`/mnt/data`).
- `UNITE_PROCESS_LIMIT` - maximum number of concurrent processes (`1`). If the limit is reached, the service returns `501`. Keep it at `1`: the intermediate step files have fixed names in the shared working directory.

## Usage
- Place `metadata.tsv`, `options.json` and the IDAT files to the `{proc}` subdirectory of the data directory (`/mnt/data/{proc}` in the container).
- Send a `POST` request to `/api/run?key={proc}`.
- The service runs `Rscript run.R /mnt/data/{proc}/metadata.tsv /mnt/data/{proc}/options.json /mnt/data/{proc}/results.tsv` and returns `200` with the script output, or `500` if the script fails.

### Input files
`metadata.tsv` - samples. The scripts use the following columns, other columns are ignored:
- `sample_id` - sample identifier.
- `path` - path of the sample IDAT files without the channel suffix and extension (`{path}_Red.idat` and `{path}_Grn.idat` are read). The path has to be valid in the runner container.

```tsv
sample_id	donor_id	specimen_type	path
D001	D001	Material	/mnt/data/{proc}/D001/203711230017_R01C01
D002	D002	Material	/mnt/data/{proc}/D002/203711230017_R02C01
```

The analysis service writes [sample metadata](https://github.com/dkfz-unite/unite-analysis/blob/main/Docs/api-model-sample-metadata.md) with the `path` column, stores the IDAT files of each sample in the `{proc}/{sample_id}` directory and writes absolute paths (so the data directory has to be mounted at the same path as in the analysis service, `/mnt/data`).

`options.json` - preprocessing options:
- `pp` - minfi preprocessing method: `"Illumina"` (`preprocessIllumina`, also used for any other value), `"SWAN"` (`preprocessSWAN`), `"Quantile"` (`preprocessQuantile`), `"Noob"` (`preprocessNoob`), `"Raw"` (`preprocessRaw`).

```json
{
  "pp": "Illumina"
}
```

### Output files
`results.tsv` - PCA scores: `Sample` (`sample_id`) and principal component columns `PC1` ... `PCn`.

```tsv
Sample	PC1	PC2	PC3
D001	-120.53	15.22	3.41
D002	98.17	-7.65	-1.02
```

## Installation

### Docker Compose
The easiest way to install the application is to use docker-compose:
- [Environment configuration and installation scripts](https://github.com/dkfz-unite/unite-env)
- [PCAM analysis service configuration and installation scripts](https://github.com/dkfz-unite/unite-env/tree/main/applications/unite-analysis-pcam)

### Docker
The image of the service is available in our [registry](https://github.com/dkfz-unite/unite-analysis-pcam/pkgs/container/unite-analysis-pcam).

The image is built by the [docker-images](.github/workflows/docker-images.yml) workflow on pushes to `main`: it checks out [unite-commands](https://github.com/dkfz-unite/unite-commands), publishes it with `publish-linux-x64.sh` and `publish-linux-arm64.sh`, copies the result (`commands` executable) to `./app`, builds amd64 and arm64 images with the [Dockerfile](Dockerfile) and pushes them under one `latest` manifest.

To build an image locally, publish unite-commands for the target platform to `./app` first (the `app` directory in the repository is replaced by the workflow and may not match the target platform or the current unite-commands version):
```bash
# in the unite-commands repository
sh publish-linux-x64.sh # or publish-linux-arm64.sh

# in this repository
rm -rf app
cp -r ../unite-commands/publish/linux-x64 app
chmod a+rx app/commands
docker build -t unite.analysis.pcam:latest .
```

All application components should run in the same docker network.
To create common docker network if not yet available run the following command:
```bash
docker network create unite
```

To run application in docker run the following command:
```bash
docker run \
--name unite.analysis.pcam \
--restart unless-stopped \
--net unite \
--net-alias pcam.analysis.unite.net \
-p 127.0.0.1:5308:80 \
-e ASPNETCORE_ENVIRONMENT=Release \
-v unite.analysis.data:/mnt/data:rw \
-d \
unite.analysis.pcam:latest
```

The volume `unite.analysis.data` is the analysis data directory shared with the analysis service and has to be mounted at the same path (`/mnt/data`), because `metadata.tsv` contains absolute paths.
