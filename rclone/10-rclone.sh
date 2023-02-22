#!/bin/sh
CONTAINER=rclone

if podman container exists "$CONTAINER"; then
  podman start "$CONTAINER"
else
  podman run -i -d --rm \
    --net=host \
    -v /data/rclone:/data/backups/rclone \
    -v /data/pihole:/data/backups/pihole \
    -v /data/on_boot.d:/data/backups/on_boot.d \
    -v /data/unifi/data/backup/autobackup:/data/backups//data/unifi/data/backup/autobackup \
    -v /data/podman/cni:/data/backups/podman/cni \
    -v /data/rclone:/config/rclone \
    -v /data/rclone/sync.sh:/data/sync.sh \
    --name "$CONTAINER" \
    --security-opt=no-new-privileges \
    rclone/rclone:latest \
    rcd --rc-web-gui --rc-addr :5572 \
    --rc-user rclone --rc-pass randompassword12345
fi