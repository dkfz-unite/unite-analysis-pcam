FROM ubuntu:latest AS install
RUN apt-get update && apt-get install -y curl bzip2
COPY environment.yml /tmp/environment.yml
RUN curl -Ls https://micro.mamba.pm/install.sh | bash && \
    export MAMBA_EXE='/root/.local/bin/micromamba' && \
    export MAMBA_ROOT_PREFIX='/root/micromamba' && \
    eval "$("$MAMBA_EXE" shell hook --shell posix)" && \
    micromamba create -n r-env -f /tmp/environment.yml && \
    micromamba clean --all --yes
# RUN curl -Ls https://micro.mamba.pm/install.sh | bash && \
#     source ~/.bashrc && \
#     micromamba create -n r-env -f /tmp/environment.yml && \
#     micromamba clean --all --yes

# RUN micromamba create -n r-env -f /tmp/environment.yml && \
#     micromamba clean --all --yes

COPY ./src /src
WORKDIR /src
COPY ./app /app
WORKDIR /app

FROM install AS final
COPY ./src/run /src
COPY ./app /app
WORKDIR /app
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
ENV ASPNETCORE_hostBuilder:reloadConfigOnChange=false
ENV UNITE_COMMAND="Rscript"
ENV UNITE_COMMAND_ARGUMENTS="run.R {data}/{proc}/metadata.tsv {data}/{proc}/options.json {data}/{proc}/results.tsv"
ENV UNITE_SOURCE_PATH="/src"
ENV UNITE_DATA_PATH="/mnt/data"
ENV UNITE_PROCESS_LIMIT="1"
EXPOSE 80
CMD ["/app/commands", "--urls", "http://0.0.0.0:80"]