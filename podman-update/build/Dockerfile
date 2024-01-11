# syntax=docker/dockerfile:experimental
FROM rust as rust
RUN mkdir -p /tmp/work
WORKDIR /tmp/work
ARG NETAVARK_VERSION=v1.9.0
RUN apt-get update && apt-get install -y \
    bc \
    binutils-aarch64-linux-gnu \
    build-essential \
    flex \
    gcc-aarch64-linux-gnu \
    libc6-arm64-cross \
    libc6-dev-arm64-cross \
    libssl-dev \
    pkg-config \
    protobuf-compiler

RUN git clone https://github.com/containers/netavark/ && mkdir -p  /tmp/work/netavark/.cargo &&  mkdir -p /tmp/work/netavark/targets &&  mkdir -p /tmp/work/netavark/bin
WORKDIR /tmp/work/netavark
COPY config.toml ./.cargo/config.toml
COPY ./net.Makefile.patch /tmp
RUN git checkout ${NETAVARK_VERSION} && rustup target add aarch64-unknown-linux-gnu && patch Makefile /tmp/net.Makefile.patch && make build

FROM golang:1.21.6-bookworm

# Currenrtly supported versions: UDM-Base UDM-Pro-SE
ARG UDM_PLATFORM=UDM-Base

ARG PODMAN_VERSION=v4.5.0
ARG RUNC_VERSION=v1.1.4
ARG CONMON_VERSION=v2.1.7
ARG CRUN_VERSION=1.8.4
ARG DEBIAN_FRONTEND=noninteractive


RUN mkdir -p /tmp/install/podman-${PODMAN_VERSION}-${UDM_PLATFORM}/usr/bin \
    && mkdir -p /tmp/install/podman-${PODMAN_VERSION}-${UDM_PLATFORM}/usr/libexec/podman/ \
    && mkdir -p /tmp/install/podman-${PODMAN_VERSION}-${UDM_PLATFORM}/usr/share/containers/ \
    && mkdir -p /tmp/install/podman-${PODMAN_VERSION}-${UDM_PLATFORM}/etc/containers/
    
COPY --from=rust /tmp/work/netavark/bin/* /tmp/install/podman-${PODMAN_VERSION}-${UDM_PLATFORM}/usr/libexec/podman
# Install dependencies
RUN dpkg --add-architecture arm64 && apt-get update && apt-get install -y \
    gperf:arm64 \
    libglib2.0-dev:arm64 \
    libseccomp-dev:arm64 \
    libsystemd-dev:arm64 \
    bc \
    binutils-aarch64-linux-gnu \
    bison \
    build-essential \
    flex \
    gcc-aarch64-linux-gnu \
    git \
    libc6-arm64-cross \
    libc6-dev-arm64-cross \
    libncurses5-dev \
    libssl-dev \
    pkg-config \
    systemd \
    zip \
  && rm -rf /var/lib/apt/lists/*
  

ENV GOOS=linux

RUN curl -L https://github.com/containers/crun/releases/download/${CRUN_VERSION}/crun-${CRUN_VERSION}-linux-arm64 -o /tmp/install/podman-${PODMAN_VERSION}-${UDM_PLATFORM}/usr/bin/crun
COPY ./podman.Makefile.${UDM_PLATFORM}.patch /tmp
RUN mkdir -p /build \
    && mkdir -p /tmp/release
WORKDIR /build
RUN git clone https://github.com/containers/podman.git \
    && git clone https://github.com/opencontainers/runc.git \
    && git clone https://github.com/containers/conmon.git
WORKDIR /build/runc

RUN git checkout ${RUNC_VERSION} \
    && ./script/release_build.sh -a arm64 -r /tmp/release
ENV PKG_CONFIG_PATH=/usr/lib/aarch64-linux-gnu/pkgconfig/
ENV GOARCH=arm64
ENV CC='aarch64-linux-gnu-gcc'
WORKDIR /build/podman
RUN git checkout ${PODMAN_VERSION} \
    && patch Makefile /tmp/podman.Makefile.${UDM_PLATFORM}.patch \
    && make vendor local-cross \
    && cp ./bin/podman.cross.linux.arm64 /tmp/release/podman-${PODMAN_VERSION} \
    && chmod +x /tmp/release/podman-${PODMAN_VERSION}

WORKDIR /build/conmon
RUN git checkout ${CONMON_VERSION} \
    && make vendor bin/conmon \
    && cp bin/conmon /tmp/release/conmon-${CONMON_VERSION} \
    && chmod +x /tmp/release/conmon-$CONMON_VERSION


COPY seccomp.json /tmp/install/podman-${PODMAN_VERSION}-${UDM_PLATFORM}/usr/share/containers/
COPY containers.conf  /tmp/install/podman-${PODMAN_VERSION}-${UDM_PLATFORM}/etc/containers/
COPY storage.conf /tmp/install/podman-${PODMAN_VERSION}-${UDM_PLATFORM}/etc/containers/
COPY registries.conf /tmp/install/podman-${PODMAN_VERSION}-${UDM_PLATFORM}/etc/containers/
COPY policy.json /tmp/install/podman-${PODMAN_VERSION}-${UDM_PLATFORM}/etc/containers/
RUN cp /tmp/release/podman-${PODMAN_VERSION} /tmp/install/podman-${PODMAN_VERSION}-${UDM_PLATFORM}/usr/bin/podman \
    && cp /tmp/release/runc.arm64 /tmp/install/podman-${PODMAN_VERSION}-${UDM_PLATFORM}/usr/bin/runc \
    && cp /tmp/release/conmon-${CONMON_VERSION} /tmp/install/podman-${PODMAN_VERSION}-${UDM_PLATFORM}/usr/libexec/podman/conmon
    
WORKDIR /tmp/install
