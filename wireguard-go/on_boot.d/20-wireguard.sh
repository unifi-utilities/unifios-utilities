#!/bin/sh

# Starts a wireguard container that is deleted after it is stopped.
# All configs stored in /mnt/data/wireguard

podman run -i -d --rm --net=host --name wireguard --privileged \
    -v /mnt/data/wireguard:/etc/wireguard \
    -v /dev/net/tun:/dev/net/tun \
    -e LOG_LEVEL=info -e WG_COLOR_MODE=always \
    masipcat/wireguard-go
