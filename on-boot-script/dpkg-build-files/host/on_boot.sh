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

