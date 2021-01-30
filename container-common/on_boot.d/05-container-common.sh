#!/bin/sh
# This script runs before any custom containers start to adjust container common defaults

## network configuration and startup:
CNI_PATH=/mnt/data/podman/cni
if [ ! -f "$CNI_PATH"/macvlan ]; then
    mkdir -p $CNI_PATH
    curl -L https://github.com/containernetworking/plugins/releases/download/v0.9.0/cni-plugins-linux-arm64-v0.9.0.tgz | tar -xz -C $CNI_PATH
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

# Set a limit for container logs. 104857600 Bytes = 100 Megabytes
sed -i 's/max_log_size = -1/max_log_size = 104857600/g' /etc/containers/libpod.conf;
