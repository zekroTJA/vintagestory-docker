ARG RUNTIME_VERSION="7.0"

FROM mcr.microsoft.com/dotnet/runtime:${RUNTIME_VERSION}

ARG VERSION="1.20.9"
ARG CHANNEL="stable"

WORKDIR /server
COPY scripts /var/scripts
RUN chmod +x /var/scripts/*.sh
RUN apt-get update && apt-get install -y curl zip rclone
RUN curl -sSf -o server.tar.gz https://cdn.vintagestory.at/gamefiles/${CHANNEL}/vs_server_linux-x64_${VERSION}.tar.gz \
    && tar -xzvf server.tar.gz \
    && rm server.tar.gz

ENV DATA_PATH="/var/vinstagestory"
ENV PRE_START_BACKUP="true"
ENV POST_START_BACKUP="false"
ENV BACKUP_FILE_FORMAT="%Y-%m-%d-%H-%M-%S"
ENV MAX_AGE_BACKUP_FILES="30d"
ENV BACKUP_TARGET="backup:/"

EXPOSE 42420

ENTRYPOINT [ "/var/scripts/entrypoint.sh" ]