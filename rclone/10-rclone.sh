#!/bin/bash
CONTAINER=rclone
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
if [ ! -d "${DATA_DIR}/backups" ]; then
  # If it does not exist, create the directory
  mkdir -p "${DATA_DIR}/backups"
  echo "Directory '${DATA_DIR}/backups' created."
else
  # If it already exists, print a message
  echo "Directory '${DATA_DIR}/backups' already exists. Moving on."
fi

if podman container exists "$CONTAINER"; then
  podman start "$CONTAINER"
else
  podman run -i -d --rm \
    --net=host \
    -v ${DATA_DIR}/rclone:${DATA_DIR}/backups/rclone \
    -v ${DATA_DIR}/pihole:${DATA_DIR}/backups/pihole \
    -v ${DATA_DIR}/on_boot.d:${DATA_DIR}/backups/on_boot.d \
    -v ${DATA_DIR}/unifi/data/backup/autobackup:${DATA_DIR}/backup/unifi/autobackup \
    -v ${DATA_DIR}/podman/cni:${DATA_DIR}/backups/podman/cni \
    -v ${DATA_DIR}/rclone:/config/rclone \
    -v ${DATA_DIR}/rclone/sync.sh:${DATA_DIR}/sync.sh \
    --name "$CONTAINER" \
    --security-opt=no-new-privileges \
    rclone/rclone:latest \
    rcd --rc-web-gui --rc-addr :5572 \
    --rc-user rclone --rc-pass randompassword12345
fi
