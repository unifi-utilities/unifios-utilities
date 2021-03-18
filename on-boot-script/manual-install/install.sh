#!/bin/sh

# Download and install the service
podman exec unifi-os curl -fsSLo /lib/systemd/system/udm-boot.service https://raw.githubusercontent.com/boostchicken/udm-utilities/master/on-boot-script/dpkg-build-files/udm-boot.service

# If you want to manually install this offline,
# Have that file downloaded first, scp it to udm (e.g. /tmp/udm-boot.service)
# Then copy it from host to container with this command:
#
#   podman cp /tmp/udm-boot.service unifi-os:/lib/systemd/system/udm-boot.service

# Start the service
podman exec unifi-os systemctl enable --now udm-boot.service