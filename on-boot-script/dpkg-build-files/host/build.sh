#!/bin/sh

set -ex

podman build . -f Dockerfile.systemd -t localhost/systemd
podman build . -f Dockerfile.podman -t localhost/podman
podman build . -f Dockerfile -t localhost/udm-boot
podman image prune

