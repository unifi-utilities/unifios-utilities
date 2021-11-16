#!/bin/sh

podman stop pihole
podman rm pihole
podman pull boostchicken/pihole-dote:latest
podman run -d --network dns --restart always \
    --name pihole \
    -e TZ="America/Chicago" \
    -v "/mnt/data/etc-pihole/:/etc/pihole/" \
    -v "/mnt/data/pihole/etc-dnsmasq.d/:/etc/dnsmasq.d/" \
    --dns=127.0.0.1 \
    --hostname pi.hole \
    -e DOTE_OPTS="-s 127.0.0.1:5053 -m 10" \
    -e VIRTUAL_HOST="pi.hole" \
    -e PROXY_LOCATION="pi.hole" \
    -e PIHOLE_DNS_="127.0.0.1#5053" \
    -e ServerIP="10.0.5.3" \
    -e IPv6="False" \
    boostchicken/pihole-dote:latest
