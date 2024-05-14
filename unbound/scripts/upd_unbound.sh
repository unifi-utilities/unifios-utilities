#!/bin/bash
# Get DataDir location
DATA_DIR="/data"
case "$(ubnt-device-info firmware || true)" in
1*)
    DATA_DIR="/mnt/data"
    ;;
2*)
    DATA_DIR="/data"
    ;;
3*)
    DATA_DIR="/data"
    ;;
4*)
    DATA_DIR="/data"
    ;;
*)
    echo "ERROR: No persistent storage found." 1>&2
    exit 1
    ;;
esac

# Check if the directory exists
if [ ! -d "${DATA_DIR}/unbound" ]; then
    # If it does not exist, create the directory
    mkdir -p "${DATA_DIR}/unbound"
    mkdir -p "${DATA_DIR}/unbound/unbound.conf.d"
    echo "Directory '${DATA_DIR}/unbound' created."
else
    # If it already exists, print a message
    echo "Directory '${DATA_DIR}/unbound' already exists. Moving on."
fi

CONTAINER=unbound
IMAGE=klutchell/unbound:latest

echo "Pulling image..."
podman pull $IMAGE
echo "Stopping container..."
podman stop $CONTAINER
echo "Removing container..."
podman rm $CONTAINER
echo "Updating root hints..."
curl -m 30 -o ${DATA_DIR}/unbound/unbound.conf.d/root.hints https://www.internic.net/domain/named.root
echo "Running $CONTAINER container"
podman run -d --net unbound --restart always \
    --name $CONTAINER \
    -v "${DATA_DIR}/unbound/unbound.conf.d/:/opt/unbound/etc/unbound/ " \
    $IMAGE
