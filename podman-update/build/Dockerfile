FROM golang:1.16-stretch


ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y zip git pkg-config libc6-arm64-cross libc6-dev-arm64-cross binutils-aarch64-linux-gnu libncurses5-dev build-essential bison flex libssl-dev bc gcc-aarch64-linux-gnu
RUN dpkg --add-architecture arm64 && apt-get update && apt-get install -y libseccomp-dev:arm64  libglib2.0-dev:arm64 gperf:arm64
ARG PODMAN_VERSION=v3.4.4
ARG RUNC_VERSION=v1.1.0
ARG CONMON_VERSION=v2.1.0

ENV GOOS=linux

COPY ./podman.Makefile.patch /tmp
COPY ./runc.Makefile.patch /tmp
RUN mkdir -p /build && mkdir -p /tmp/release
WORKDIR /build
RUN  git clone https://github.com/containers/podman && git clone https://github.com/opencontainers/runc && git clone https://github.com/containers/conmon
WORKDIR /build/runc

RUN git checkout $RUNC_VERSION && ./script/release_build.sh -a arm64 -r /tmp/release
ENV PKG_CONFIG_PATH=/usr/lib/aarch64-linux-gnu/pkgconfig/
ENV GOARCH=arm64
ENV CC='aarch64-linux-gnu-gcc'
WORKDIR /build/podman
RUN git checkout $PODMAN_VERSION && patch Makefile /tmp/podman.Makefile.patch && make vendor local-cross && \
    cp ./bin/podman.cross.linux.arm64 /tmp/release/podman-$PODMAN_VERSION && chmod +x /tmp/release/podman-$PODMAN_VERSION


WORKDIR /build/conmon
RUN git checkout $CONMON_VERSION && make vendor bin/conmon && cp bin/conmon /tmp/release/conmon-$CONMON_VERSION && chmod +x /tmp/release/conmon-$CONMON_VERSION

RUN mkdir -p /tmp/install/usr/bin && mkdir -p /tmp/install/usr/libexec/podman/ && mkdir -p /tmp/install/usr/share/containers/ && mkdir -p /tmp/install/etc/containers/
COPY seccomp.json /tmp/install/usr/share/containers/
COPY containers.conf /tmp/install/etc/containers/

RUN cp /tmp/release/podman-$PODMAN_VERSION /tmp/install/usr/bin/podman && cp /tmp/release/runc.arm64 /tmp/install/usr/bin/runc && cp /tmp/release/conmon-$CONMON_VERSION /tmp/install/usr/libexec/podman/conmon
WORKDIR /tmp/install
RUN zip -r /tmp/release/podman-install.zip *


