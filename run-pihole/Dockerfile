# docker buildx build --platform linux/amd64,linux/arm64 . -t docker.io/boostchicken/pihole:latest --push
ARG VERSION
FROM pihole/pihole:$VERSION

ENV CLOUDFLARED_OPTS="--port 5053 --address 0.0.0.0"
COPY 10-cloudflared.sh /etc/cont-init.d/
