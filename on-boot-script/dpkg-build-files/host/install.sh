#!/bin/sh

set -e

mkdir -p /mnt/data/udm-boot/on_boot.d
chmod +x /mnt/data/udm-boot/on_boot.sh

# import new udm-boot image
iid=$(podman pull oci-archive:/mnt/data/udm-boot/udm-boot_arm64.tar)
echo $iid
podman tag $iid udm-boot

# TODO: should we delete udm-boot_arm64.tar here to save space?

# cleanup old udm-boot container
/mnt/data/udm-boot/uninstall.sh

# create new udm-boot container
/usr/bin/podman create \
	--conmon-pidfile "/run/udm-boot.service-pid" \
	--cidfile "/run/udm-boot.service-cid" \
	--tty \
	--detach \
	--privileged \
	--network host \
	--hostname udm-boot \
	--name udm-boot \
	--volume "/sys/fs/cgroup:/sys/fs/cgroup:ro" \
	--volume "/etc/localtime:/etc/localtime:ro" \
	udm-boot

# cleanup and move legacy udm-boot files
if [ -d /mnt/data/on_boot.d ]; then
	if [ ! -z "$(ls -A /mnt/data/on_boot.d/*)" ]; then
		mv -v /mnt/data/on_boot.d/* /mnt/data/udm-boot/on_boot.d/
	fi
	rmdir -v /mnt/data/on_boot.d
fi
if [ -f /mnt/data/on_boot.sh ]; then
	rm -v /mnt/data/on_boot.sh
fi


