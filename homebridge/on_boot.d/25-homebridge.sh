#!/bin/sh
CONTAINER=homebridge

# Starts the homebridge container on boot.
# All configs stored in /mnt/data/homebridge

if podman container exists ${CONTAINER}; then
  podman start ${CONTAINER}
else
  logger -s -t homebridge -p ERROR Container $CONTAINER not found, make sure you set the proper name, you can ignore this error if it is your first time setting it up
fi

