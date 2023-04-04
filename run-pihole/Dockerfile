ARG VERSION=2023.03.1
FROM pihole/pihole:${VERSION}

ENV CLOUDFLARED_OPTS="--port 5053 --address 0.0.0.0"

COPY 10-cloudflared.sh /etc/cont-init.d/
RUN chmod +x /etc/cont-init.d/10-cloudflared.sh
