#!/bin/bash
# This script installs systemd-container if it's not installed.
# Also links any containers from /data/custom/machines to /var/lib/machines.

set -e

if ! dpkg -l systemd-container | grep ii >/dev/null; then
    if ! apt -y install systemd-container debootstrap; then
        yes | dpkg -i /data/custom/dpkg/*.deb
    fi
fi

mkdir -p /var/lib/machines
for machine in $(ls /data/custom/machines/); do
	if [ ! -e "/var/lib/machines/$machine" ]; then
		ln -s "/data/custom/machines/$machine" "/var/lib/machines/"
		machinectl enable $machine
		machinectl start $machine
	fi
done
