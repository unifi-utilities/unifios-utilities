#!/bin/sh

podman cp install-unifios.sh unifi-os:/root/install-unifios.sh
podman exec unifi-os chmod +x /root/install-unifios.sh
podman exec unifi-os sh -c /root/install-unifios.sh
