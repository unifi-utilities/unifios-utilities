#!/bin/bash
CONTAINER=haproxy
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
if [ ! -d "${DATA_DIR}/haproxy" ]; then
  # If it does not exist, create the directory
  mkdir -p "${DATA_DIR}/haproxy"
  echo "Directory '${DATA_DIR}/haproxy' created."
else
  # If it already exists, print a message
  echo "Directory '${DATA_DIR}/haproxy' already exists. Moving on."
fi

# Starts an haproxy container that is deleted after it is stopped.
# All configs stored in /data/haproxy
if podman container exists "$CONTAINER"; then
  podman start "$CONTAINER"
else
  podman run -d --net=host --restart always \
    --name haproxy \
    --hostname ha.proxy \
    -v "${DATA_DIR}/haproxy/:/usr/local/etc/haproxy/" \
    haproxy:latest
fi
