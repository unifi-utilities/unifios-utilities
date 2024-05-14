#!/bin/bash

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

# Check if the directory exists
if [ ! -d "${DATA_DIR}/wireguard" ]; then
  # If it does not exist, create the directory
  mkdir -p "${DATA_DIR}/wireguard"
  echo "Directory '${DATA_DIR}/wireguard' created."
else
  # If it already exists, print a message
  echo "Directory '${DATA_DIR}/wireguard' already exists. Moving on."
fi

CONTAINER=wireguard
# Starts a wireguard container that is deleted after it is stopped.
# All configs stored in ${DATA_DIR}/wireguard
if podman container exists ${CONTAINER}; then
  podman start ${CONTAINER}
else
  podman run -i -d --rm --net=host --name ${CONTAINER} --privileged \
    -v ${DATA_DIR}/wireguard:/etc/wireguard \
    -v /dev/net/tun:/dev/net/tun \
    -e LOG_LEVEL=info -e WG_COLOR_MODE=always \
    masipcat/wireguard-go:0.0.20210424
fi
