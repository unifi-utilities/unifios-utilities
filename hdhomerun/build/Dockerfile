# Note: map a volume to /tmp/release to accept the binary.
# ```
# docker build -t build_socat .

FROM aarch64/gcc

ARG SOCAT_VERSION=1.7.4.3
ARG READLINE_VERSION=7.0
ARG OPENSSL_VERSION=1.0.2k

# Make directories
RUN mkdir -p /build && mkdir -p /tmp/release
WORKDIR /build

# Build readline
RUN curl -k -LO ftp://ftp.cwru.edu/pub/bash/readline-${READLINE_VERSION}.tar.gz
RUN tar xzvf readline-${READLINE_VERSION}.tar.gz
WORKDIR  /build/readline-${READLINE_VERSION}
RUN ./configure -disable-shared --enable-static -build=aarch64
RUN make -j4
RUN make install-static

# Build OpenSSL
WORKDIR /build
RUN curl -k -LO https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
RUN tar zxvf openssl-${OPENSSL_VERSION}.tar.gz
WORKDIR /build/openssl-${OPENSSL_VERSION}
ENV CFLAGS='-fPIC -static'
RUN ./Configure no-shared linux-aarch64
RUN make -j4
RUN make install

# Build socat
WORKDIR /build
RUN curl -k -LO http://www.dest-unreach.org/socat/download/socat-${SOCAT_VERSION}.tar.gz
RUN tar xzvf socat-${SOCAT_VERSION}.tar.gz
WORKDIR /build/socat-${SOCAT_VERSION}
ENV LDFLAGS='-static -ldl -ltinfo'
RUN ./configure -build=linux-aarch64
RUN make -j4

# Copy the file to the release directory
ENTRYPOINT cp socat /tmp/release
