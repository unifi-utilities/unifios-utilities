FROM alpine
ENV VERSION=1.6.4
LABEL maintainer="John Dorman <dorman@ataxia.cloud>"
RUN apk add --no-cache ca-certificates \
    && mkdir -p /opt/nextdns \
    && wget -O /tmp/nextdns.tar.gz https://github.com/nextdns/nextdns/releases/download/v${VERSION}/nextdns_${VERSION}_linux_arm64.tar.gz  \
    && tar zxf /tmp/nextdns.tar.gz -C /opt/nextdns \
    && rm /tmp/nextdns.tar.gz
EXPOSE 53/tcp 53/udp
ENTRYPOINT ["/opt/nextdns/nextdns","run", "-config-file", "/etc/nextdns/nextdns.conf"]
CMD []