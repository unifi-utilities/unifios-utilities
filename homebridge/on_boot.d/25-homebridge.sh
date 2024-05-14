#!/bin/bash
CONTAINER=homebridge

# Get DataDir location
DATA_DIR="/data"
case "$(ubnt-device-info firmware || true)" in
1*)
    DATA_DIR="/mnt/data"
    ;;
2* | 3* | 4*)
    DATA_DIR="/data"
    ;;
*)
    echo "ERROR: No persistent storage found." 1>&2
    exit 1
    ;;
esac 
## network configuration and startup:
CNI_PATH=${DATA_DIR}/podman/cni
# Check if the directory exists
if [ ! -d "$CNI_PATH" ]; then
  # If it does not exist, create the directory
  mkdir -p "$CNI_PATH"
  echo "Directory '$CNI_PATH' created."
else
  # If it already exists, print a message
  echo "Directory '$CNI_PATH' already exists. Moving on."
fi

if [ ! -f "$CNI_PATH"/tuning ]; then
  mkdir -p $CNI_PATH
  curl -L https://github.com/containernetworking/plugins/releases/download/v0.9.1/cni-plugins-linux-arm64-v0.9.1.tgz | tar -xz -C $CNI_PATH
fi

mkdir -p /opt/cni
rm -f /opt/cni/bin
ln -s $CNI_PATH /opt/cni/bin

for file in "$CNI_PATH"/*.conflist; do
  if [ -f "$file" ]; then
    ln -s "$file" "/etc/cni/net.d/$(basename "$file")"
  fi
done

# Starts the homebridge container on boot.
# All configs stored in /data/homebridge

if podman container exists ${CONTAINER}; then
  podman start ${CONTAINER}
else
  logger -s -t homebridge -p ERROR Container $CONTAINER not found, make sure you set the proper name, you can ignore this error if it is your first time setting it up
fi
