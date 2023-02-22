#!/bin/sh
CONTAINER=haproxy

# Starts an haproxy container that is deleted after it is stopped.
# All configs stored in /data/haproxy
if podman container exists "$CONTAINER"; then
  podman start "$CONTAINER"
else
  podman run -d --net=host --restart always \
    --name haproxy \
    --hostname ha.proxy \
    -v "/data/haproxy/:/usr/local/etc/haproxy/" \
    haproxy:latest
fi
