FROM golang:1.17-bullseye AS build-image

# build rclone
ARG RCLONE_BRANCH=v1.56.0

RUN git clone --depth 1 --branch $RCLONE_BRANCH https://github.com/rclone/rclone.git
RUN cd rclone && go build -ldflags "-linkmode external -extldflags -static"

# build kopia
ARG KOPIA_BRANCH=v0.8.4

RUN git clone --depth 1 --branch $KOPIA_BRANCH https://github.com/kopia/kopia.git

ARG KOPIA_BUILD_TYPE

COPY build_kopia.sh kopia/build_kopia.sh
RUN chmod +x kopia/build_kopia.sh
RUN cd kopia && ./build_kopia.sh


FROM alpine:3.14

COPY --from=build-image /go/rclone/rclone /usr/bin/
COPY --from=build-image /go/bin/kopia /usr/bin/

RUN mkdir -p /kopia/config && mkdir -p /kopia/cache && mkdir -p /rclone

ENV KOPIA_CONFIG_PATH=/kopia/config/repository.config
ENV KOPIA_LOG_DIR=/kopia/logs
ENV KOPIA_CACHE_DIRECTORY=/kopia/cache
ENV KOPIA_CHECK_FOR_UPDATES=false

ENV RCLONE_CONFIG=/rclone/rclone.conf

LABEL org.opencontainers.image.source="https://github.com/infinityofspace/kopia_rclone_docker"
LABEL org.opencontainers.image.licenses="MIT"
