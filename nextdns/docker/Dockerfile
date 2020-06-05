FROM debian:buster-slim
LABEL maintainer="John Dorman <dorman@ataxia.cloud>"

ENV VERSION=1.6.4
RUN apt update && apt install -y curl \
    && mkdir -p /opt/nextdns \
    && curl -fsSL https://github.com/nextdns/nextdns/releases/download/v${VERSION}/nextdns_${VERSION}_linux_arm64.tar.gz -o /tmp/nextdns.tar.gz \
    && tar zxf  /tmp/nextdns.tar.gz -C /opt/nextdns

EXPOSE 53/tcp 53/udp

ENTRYPOINT ["/opt/nextdns/nextdns","run", "-config-file", "/etc/nextdns/nextdns.conf"]