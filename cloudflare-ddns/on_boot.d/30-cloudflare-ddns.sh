#!/bin/bash
CONTAINER=cloudflare-ddns
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
if [ ! -d "$DATA_DIR/cloudflare-ddns" ]; then
  # If it does not exist, create the directory
  mkdir -p "$DATA_DIR/cloudflare-ddns"
  echo "Directory '$DATA_DIR/cloudflare-ddns' created."
else
  # If it already exists, print a message
  echo "Directory '$DATA_DIR/cloudflare-ddns' already exists. Moving on."
fi

# Starts a cloudflare ddns container that is deleted after it is stopped.
# All configs stored in /data/cloudflare-ddns
if podman container exists "$CONTAINER"; then
  podman start "$CONTAINER"
else
  podman run -i -d --rm \
    --net=host \
    --name "$CONTAINER" \
    --security-opt=no-new-privileges \
    -v $DATA_DIR/cloudflare-ddns/config.json:/config.json \
    timothyjmiller/cloudflare-ddns:latest
fi
