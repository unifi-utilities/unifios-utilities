#!/bin/sh
CONTAINER=zerotier-one
# Starts a wireguard container that is deleted after it is stopped.
# All configs stored in /mnt/data/wireguard
if podman container exists ${CONTAINER}; then
  podman start ${CONTAINER}
else
  podman run --device=/dev/net/tun --net=host --cap-add=NET_ADMIN --cap-add=SYS_ADMIN --cap-add=CAP_SYS_RAWIO -v /mnt/data/zerotier-one:/var/lib/zerotier-one --name zerotier-one -d bltavares/zerotier
fi

