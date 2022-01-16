# UDM / UDMPro Boot Script

## Features

1. Allows you to run a shell script at S95 anytime your UDM starts / reboots
1. Persists through reboot and **firmware updates**! It is able to do this because Ubiquiti caches all debian package installs on the UDM in /mnt/data, then re-installs them on reset of unifi-os container.

## Compatibility

1. Should work on any UDM/UDMPro after 1.6.3
2. Tested and confirmed on 1.6.6, 1.7.0, 1.7.2rc4, 1.7.3rc1, 1.8.0rc7, 1.8.0+

### Upgrade from earlier way

* As long as you didn't change the filenames, installing the deb package is all you need to do.  If you want to clean up beforehand anyways....

    ```bash
    rm /etc/init.d/udm.sh
    systemctl disable udmboot
    rm /etc/systemd/system/udmboot.service
    ```

* [build_deb.sh](build_deb.sh) can be used to build the package by yourself.
    * [dpkg-build-files](dpkg-build-files) contains the sources that debuild uses to build the package if you want to build it yourself / change it
    * by default it uses docker or podman to build the debian package
    * use ```./build_deb.sh build``` to not use a container
    * the resulting package will be in [packages/](packages/)

* Built on Ubuntu-20.04 on Windows 10/WSL2

## Install

You can execute in UDM/Pro/SE and UDR with:

```bash
curl -fsL "https://raw.githubusercontent.com/boostchicken/udm-utilities/HEAD/on-boot-script/remote_install.sh" | /bin/sh
```

This is a force to install script so will uninstall any previous version and install on_boot keeping your on boot files.

This will also install CNI Plugins & CNI Bridge scripts. If you are using UDMSE/UDR remember that you must install podman manually because there is no podman.

## Manually Install Steps

1. Get into the unifios shell on your udm

    ```bash
    unifi-os shell
    ```

2. Download [udm-boot_1.0.5_all.deb](packages/udm-boot_1.0.5_all.deb) and install it and go back to the UDM.  The latest package will always be found at https://udm-boot.boostchicken.dev

    ```bash
    curl -L https://udm-boot.boostchicken.dev -o udm-boot_1.0.5_all.deb
    dpkg -i udm-boot_1.0.5_all.deb
    exit
    ```

3. Copy any shell scripts you want to run to /mnt/data/on_boot.d on your UDM (not the unifi-os shell) and make sure they are executable and have the correct shebang (#!/bin/sh). Additionally, scripts need to have a `.sh` extention in their filename.

    Examples:
    * Start a DNS Container [10-dns.sh](../dns-common/on_boot.d/10-dns.sh)
    * Start wpa_supplicant [on_boot.d/10-wpa_supplicant.sh](examples/udm-files/on_boot.d/10-wpa_supplicant.sh)
    * Add a persistent ssh key for the root user [on_boot.d/15-add-root-ssh-keys.sh](examples/udm-files/on_boot.d/15-add-root-ssh-keys.sh)

## Version History

### 1.0.5

* Remove on_boot.sh from UDM
* Follow symlinks
* move to network-online.target

### 1.0.4

* Fix 600s timeout issues
* Fix rc.d policy issue

### 1.0.3

* Fix not working after firmware upgrade
* Added udm-boot.boostchicken.dev domain

### 1.0.2

* Some build improvements and more clean installation

### 1.0.1

* Fully automated install, all that is left is populating /mnt/data/on_boot.d

### 1.0.0

* First release that persists through firmware
