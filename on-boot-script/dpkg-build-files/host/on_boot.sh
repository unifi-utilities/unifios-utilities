#!/bin/sh
echo "initializing udm-boot"
echo "start legacy scripts"
if [ -d /mnt/data/udm-boot/on_boot.d ]; then
	for i in /mnt/data/udm-boot/on_boot.d/*.sh; do
		if [ -r $i ]; then
			echo "  start script $i"
			. $i
		fi
	done
fi

echo "setup systemd services and timers"
if [ -d /mnt/data/udm-boot/services.d ]; then
	for i in /mnt/data/udm-boot/services.d/*.service; do
		if [ -r $i ]; then
			echo "  copy service $(basename $i)"
			podman cp $i unifi-os:/lib/systemd/system/
			echo "  enable service $(basename $i)"
			podman exec unifi-os systemctl enable $(basename $i)
		fi
	done
	for i in /mnt/data/udm-boot/services.d/*.timer; do
		if [ -r $i ]; then
			echo "  copy timer $(basename $i)"
			podman cp $i unifi-os:/lib/systemd/system/
			echo "  enable timer $(basename $i)"
			podman exec unifi-os systemctl enable $(basename $i)
			echo "  start timer $(basename $i)"
			podman exec unifi-os systemctl start $(basename $i)
		fi
	done
fi

echo "start systemd services"
podman exec unifi-os systemctl start udm-boot-services.target
