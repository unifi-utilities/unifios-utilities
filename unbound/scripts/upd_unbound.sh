#!/bin/sh
CONTAINER=unbound
IMAGE=klutchell/unbound:latest

echo "Pulling image..."
podman pull $IMAGE
echo "Stopping container..."
podman stop $CONTAINER
echo "Removing container..."
podman rm  $CONTAINER
echo "Updating root hints..."
mkdir -p /mnt/data/unbound/unbound.conf.d/
curl -m 30 -o /mnt/data/unbound/unbound.conf.d/root.hints https://www.internic.net/domain/named.root
echo "Running $CONTAINER container"
podman run -d --net unbound --restart always \
    --name  $CONTAINER \
    -v "/mnt/data/unbound/unbound.conf.d/:/opt/unbound/etc/unbound/ " \
    $IMAGE