# UDM / UDMPro Boot Script

## Features

1. Allows you to run a shell script at S95 anytime your UDM starts / reboots
1. Persists through reboot and **firmware updates**! It is able to do this because Ubiquiti caches all debian package installs on the UDM in /mnt/data, then re-installs them on every boot

## Compatibility

1. Should work on any UDM/UDMPro after 1.6.3
2. Tested and confirmed on 1.6.6, 1.7.0, 1.7.2rc4, 1.7.3rc1, 1.8.0rc7, 1.8.0

### Upgrade from earlier way

* As long as you didn't change the filenames, installing the deb package is all you need to do.  If you want to clean up beforehand anyways....

    ```bash
    rm /etc/init.d/udm.sh
    systemctl disable udmboot
    rm /etc/systemd/system/udmboot.service
    ```

    Note: since 1.1.0 all scripts get automatically moved to /mnt/data/udm-boot/...

* [build.sh](build.sh) can be used to build the package by yourself.
    * Be sure to have at least "buildah" installed for the default container based build.
    * The following command builds everything that is needed and even deploys and install udm-boot onto your device (you need a working ssh key based auth to your udm!):
      ```bash
        export UDM_HOST=<MY UDM IP>
	./build.sh && ./build.sh deploy && ./build.sh install
      ```
    * Overview
        * [dpkg-build-files](dpkg-build-files)
          contains the most scripts and all sources that debuild uses to build the package if you want to build it yourself
        * [images](images)
          contains the dockerfiles to build the udm-boot container itself.
          for maintainability it's split in three depending files.
        * [packages/](packages)
          the required build debian package will be put here
    * Built on Ubuntu-20.04 on Windows 10/WSL2


## Steps

1. Get into the unifios shell on your udm

    ```bash
    unifi-os shell
    ```

2. Download [udm-boot_1.0.2_all.deb](packages/udm-boot_1.0.2_all.deb) and install it and go back to the UDM

    ```bash
    curl -L https://raw.githubusercontent.com/boostchicken/udm-utilities/master/on-boot-script/packages/udm-boot_1.1.0_all.deb -o udm-boot_1.1.0_all.deb
    dpkg -i udm-boot_1.1.0_all.deb
    exit
    ```

3. Copy any shell scripts you want to run to /mnt/data/udm-boot/on_boot.d on your UDM (not the unifi-os shell) and make sure they are executable and have the correct shebang (#!/bin/sh)

    Examples:
    * Start a DNS Container [10-dns.sh](../dns-common/on_boot.d/10-dns.sh)
    * Start wpa_supplicant [on_boot.d/10-wpa_supplicant.sh](examples/udm-files/on_boot.d/10-wpa_supplicant.sh)

4. Example creating a container that preserves and autostart on boot:

    * On the UDM shell (not unifi-os):
      ```bash
      podman exec -it udm-boot /bin/bash
      podman create --detach --restart always --network host --cap-add SYS_TIME --name ntpd tusc/chrony-udm
      podman generate systemd ntpd >/etc/systemd/system/ntpd.service
      systemctl daemon-reload
      systemctl enable ntpd.service
      systemctl start ntpd.service
      ```

## Uninstall

1. Get into the unifios shell on your udm

    ```bash
    unifi-os shell
    ```

2. Uninstall udm-boot (`-P` will cleanup the 

    ```bash
    dpkg -P udm-boot
    ```

3. (Optional) Cleanup data if you want. **WARNING**: this will remove all your customizations (scripts, services, containers etc.)!

    ```bash
    exit # to drop out of the unifi-os shell and execute on the udm itself
    rm -rf /mnt/data/udm-boot # delete all udm-boot data on the disk
    podman image prune # cleanup container images (not only from udm-boot, is save if you didn't create images by yourself)
    podman volume prune # cleanup container volumes (not only from udm-boot, is save if you didn't create containers or volumes by yourself)
    ```


## Version History

### 1.0.2

* Some build improvements and more clean installation

### 1.0.1

* Fully automated install, all that is left is populating /mnt/data/on_boot.d

### 1.0.0

* First release that persists through firmware
