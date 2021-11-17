FROM golang:bullseye


ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y zip git pkg-config libc6-arm64-cross libc6-dev-arm64-cross binutils-aarch64-linux-gnu libncurses5-dev build-essential bison flex libssl-dev bc gcc-aarch64-linux-gnu
RUN dpkg --add-architecture arm64 && apt-get update && apt-get install -y libseccomp-dev:arm64  && apt-get install -y libglib2.0-dev:arm64
ARG PODMAN_VERSION=v3.4.2
ARG RUNC_VERSION=v1.0.2
ARG CONMON_VERSION=v2.0.30
ENV PKG_CONFIG_PATH=/usr/lib/aarch64-linux-gnu/pkgconfig/
ENV GOOS=linux
ENV GOARCH=arm64
ENV CC='aarch64-linux-gnu-gcc'
COPY ./podman.Makefile.patch /tmp
COPY ./runc.Makefile.patch /tmp
RUN mkdir -p /build && mkdir -p /tmp/release
WORKDIR /build
RUN  git clone https://github.com/containers/podman && git clone https://github.com/opencontainers/runc && git clone https://github.com/containers/conmon
WORKDIR /build/podman
RUN git checkout $PODMAN_VERSION && patch Makefile /tmp/podman.Makefile.patch && make vendor local-cross && \
    cp ./bin/podman.cross.linux.arm64 /tmp/release/podman-$PODMAN_VERSION && chmod +x /tmp/release/podman-$PODMAN_VERSION
WORKDIR /build/runc
RUN git checkout $RUNC_VERSION && patch Makefile /tmp/runc.Makefile.patch && make vendor localcross && \
    cp ./runc-arm64 /tmp/release/runc-$RUNC_VERSION && chmod +x /tmp/release/runc-$RUNC_VERSION

WORKDIR /build/conmon
RUN git checkout $CONMON_VERSION && make vendor bin/conmon && cp bin/conmon /tmp/release/conmon-$CONMON_VERSION && chmod +x /tmp/release/conmon-$CONMON_VERSION

RUN mkdir -p /tmp/install/usr/bin && mkdir -p /tmp/install/usr/libexec/podman/ && mkdir -p /tmp/install/usr/share/containers/ && mkdir -p /tmp/install/etc/containers/
COPY seccomp.json /tmp/install/usr/share/containers/
COPY containers.conf /tmp/install/etc/containers/
RUN cp /tmp/release/podman-$PODMAN_VERSION /tmp/install/usr/bin/podman && cp /tmp/release/runc-$RUNC_VERSION /tmp/install/usr/bin/runc && cp /tmp/release/conmon-$CONMON_VERSION /tmp/install/usr/libexec/podman/conmon
WORKDIR /tmp/install
RUN zip -r /tmp/release/podman-install.zip *


