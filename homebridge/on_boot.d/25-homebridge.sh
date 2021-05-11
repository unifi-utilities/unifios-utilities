#!/bin/sh
CONTAINER=homebridge

## network configuration and startup:
CNI_PATH=/mnt/data/podman/cni
if [ ! -f "$CNI_PATH"/tuning ]; then
    mkdir -p $CNI_PATH
    curl -L https://github.com/containernetworking/plugins/releases/download/v0.9.1/cni-plugins-linux-arm64-v0.9.1.tgz | tar -xz -C $CNI_PATH
fi

mkdir -p /opt/cni
rm -f /opt/cni/bin
ln -s $CNI_PATH /opt/cni/bin

for file in "$CNI_PATH"/*.conflist
do
    if [ -f "$file" ]; then
        ln -s "$file" "/etc/cni/net.d/$(basename "$file")"
    fi
done


# Starts the homebridge container on boot.
# All configs stored in /mnt/data/homebridge

if podman container exists ${CONTAINER}; then
  podman start ${CONTAINER}
else
  logger -s -t homebridge -p ERROR Container $CONTAINER not found, make sure you set the proper name, you can ignore this error if it is your first time setting it up
fi

