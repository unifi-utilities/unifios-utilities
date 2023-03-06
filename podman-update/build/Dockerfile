FROM golang:1.18.3-stretch

# Currenrtly supported versions: UDM-Pro, UDM-SE
ARG UDM_PLATFORM=UDM-Pro

ARG PODMAN_VERSION=v4.4.2
ARG RUNC_VERSION=v1.1.4
ARG CONMON_VERSION=v2.1.7

ARG DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
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
RUN dpkg --add-architecture arm64
RUN apt-get update && apt-get install -y \
    gperf:arm64 \
    libglib2.0-dev:arm64 \
    libseccomp-dev:arm64 \
    libsystemd-dev:arm64 \
  && rm -rf /var/lib/apt/lists/*

ENV GOOS=linux

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

RUN mkdir -p /tmp/install/usr/bin \
    && mkdir -p /tmp/install/usr/libexec/podman/ \
    && mkdir -p /tmp/install/usr/share/containers/ \
    && mkdir -p /tmp/install/etc/containers/
COPY seccomp.json /tmp/install/usr/share/containers/
COPY containers.conf /tmp/install/etc/containers/

RUN cp /tmp/release/podman-${PODMAN_VERSION} /tmp/install/usr/bin/podman \
    && cp /tmp/release/runc.arm64 /tmp/install/usr/bin/runc \
    && cp /tmp/release/conmon-${CONMON_VERSION} /tmp/install/usr/libexec/podman/conmon
WORKDIR /tmp/install

# Zip up the files
RUN zip -r /tmp/release/podman-install.zip *
