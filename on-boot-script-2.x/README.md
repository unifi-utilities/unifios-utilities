# UDM / UDMPro Boot Script

## Features

1. Allows you to run a shell script at S95 anytime your UDM starts / reboots

## Compatibility

1. Should work on any UDM/UDMPro after 2.4.x

- [build_deb.sh](build_deb.sh) can be used to build the package by yourself.

  - [dpkg-build-files](dpkg-build-files) contains the sources that debuild uses to build the package if you want to build it yourself / change it
  - by default it uses docker or podman to build the debian package
  - use `./build_deb.sh build` to not use a container
  - the resulting package will be in [packages/](packages/)

- Built on Ubuntu-20.04 on Windows 10/WSL2

## Install

You can execute in UDM/Pro/SE and UDR with:

```bash
curl -fsL "https://raw.githubusercontent.com/unifi-utilities/unifios-utilities/HEAD/on-boot-script-2.x/remote_install.sh" | /bin/bash
```

This is a force to install script so will uninstall any previous version and install on_boot keeping your on boot files.

This will also install CNI Plugins & CNI Bridge scripts. If you are using UDMSE/UDR remember that you must install podman manually because there is no podman.

## Manually Install Steps

1. Get into the unifios shell on your udm

   ```bash
   unifi-os shell
   ```

2. Download [udm-boot-2x_1.0.1_all.deb](packages/udm-boot-2x_1.0.1_all.deb) and install it and go back to the UDM.

   ```bash
   curl -L [[https://unifi.boostchicken.io/udm-boot-v2+/udm-boot-2x_1.0.1_all.deb](https://unifi.boostchicken.io/udm-boot-v2+/udm-boot-2x_1.0.1_all.deb)](https://unifi.boostchicken.io/udm-boot-v2+/udm-boot-2x_1.0.1_all.deb) -o udm-boot-2x_1.0.1_all.deb
   dpkg -i udm-boot-2x_1.0.1_all.deb
   systemctl enable udm-boot
   exit
   ```

3. Copy any shell scripts you want to run to /data/on_boot.d on your UDM (not the unifi-os shell) and make sure they are executable and have the correct shebang (#!/bin/bash). Additionally, scripts need to have a `.sh` extention in their filename.

   Examples:

   - Start a DNS Container [10-dns.sh](../dns-common/on_boot.d/10-dns.sh)
   - Start wpa_supplicant [on_boot.d/10-wpa_supplicant.sh](examples/udm-files/on_boot.d/10-wpa_supplicant.sh)
   - Add a persistent ssh key for the root user [on_boot.d/15-add-root-ssh-keys.sh](examples/udm-files/on_boot.d/15-add-root-ssh-keys.sh)

## Version History

### 1.0.0

- First release that persists through firmware
