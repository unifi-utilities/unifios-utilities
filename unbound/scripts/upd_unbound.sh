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
mkdir -p /data/unbound/unbound.conf.d/
curl -m 30 -o /data/unbound/unbound.conf.d/root.hints https://www.internic.net/domain/named.root
echo "Running $CONTAINER container"
podman run -d --net unbound --restart always \
    --name  $CONTAINER \
    -v "/data/unbound/unbound.conf.d/:/opt/unbound/etc/unbound/ " \
    $IMAGE