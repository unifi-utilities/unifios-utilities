#!/bin/sh

set -e

mkdir -p /mnt/data/udm-boot/on_boot.d
chmod +x /mnt/data/udm-boot/on_boot.sh
mkdir -p /mnt/data/udm-boot/data/var/lib/containers
mkdir -p /mnt/data/udm-boot/data/etc/systemd/system

# import new udm-boot image
iid=$(podman pull oci-archive:/mnt/data/udm-boot/udm-boot_arm64.tar)
echo $iid
podman tag $iid udm-boot

# TODO: should we delete udm-boot_arm64.tar here to save space?

# cleanup old udm-boot container
/mnt/data/udm-boot/uninstall.sh

if [ -d /mnt/data_ext ]; then
  mount_ext='--mount type=bind,source=/mnt/data_ext,target=/mnt/data_ext,rw=true'
fi

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
	--mount "type=bind,source=/sys/fs/cgroup,target=/sys/fs/cgroup,ro=true" \
	--mount "type=bind,source=/etc/localtime,target=/etc/localtime,ro=true" \
	--mount "type=bind,source=/mnt/data/ssh/id_rsa,target=/root/.ssh/id_rsa,ro=true" \
	--mount "type=bind,source=/var/run,target=/mnt/host_var_run,ro=true" \
	--mount "type=bind,source=/mnt/data/udm-boot/data/var/lib/containers,target=/var/lib/containers,rw=true" \
	--mount "type=bind,source=/mnt/data/udm-boot/data/etc/systemd/system,target=/etc/systemd/system,rw=true" \
        --mount "type=bind,source=/mnt/data,target=/mnt/data,rw=true" \
        ${mount_ext} \
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

