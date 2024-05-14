#!/bin/bash
# Get DataDir location
DATA_DIR="/data"case "$(ubnt-device-info firmware || true)" in
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
if [ ! -d "${DATA_DIR}/zerotier-one" ]; then
  # If it does not exist, create the directory
  mkdir -p "${DATA_DIR}/zerotier-one"
  echo "Directory '${DATA_DIR}/zerotier-one' created."
else
  # If it already exists, print a message
  echo "Directory '${DATA_DIR}/zerotier-one' already exists. Moving on."
fi

CONTAINER=zerotier-one
# Starts a ZeroTier container that is deleted after it is stopped.
# All configs stored in ${DATA_DIR}/zerotier-one
if podman container exists ${CONTAINER}; then
  podman start ${CONTAINER}
else
  podman run --device=/dev/net/tun --net=host --cap-add=NET_ADMIN --cap-add=SYS_ADMIN --cap-add=CAP_SYS_RAWIO -v ${DATA_DIR}/zerotier-one:/var/lib/zerotier-one --name zerotier-one -d zerotier/zerotier
fi
