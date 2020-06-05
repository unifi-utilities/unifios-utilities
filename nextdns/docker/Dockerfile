FROM alpine AS builder
ENV VERSION=1.6.4
WORKDIR /tmp
RUN apk add curl \
    && mkdir nextdns \
    && curl -fsSL https://github.com/nextdns/nextdns/releases/download/v${VERSION}/nextdns_${VERSION}_linux_arm64.tar.gz -o nextdns.tar.gz \
    && tar zxf nextdns.tar.gz -C ./nextdns

FROM debian:buster-slim
LABEL maintainer="John Dorman <dorman@ataxia.cloud>"
COPY --from=builder /tmp/nextdns /opt/nextdns
EXPOSE 53/tcp 53/udp
VOLUME ['/etc/nextdns']
ENTRYPOINT ["/opt/nextdns/nextdns","run", "-config-file", "/etc/nextdns/nextdns.conf"]