# UDM / UDMPro Boot Script
### Features
1. Allows you to run a shell script at S95 anytime your UDM starts / reboots
1. Persists through reboot and **firmware updates**! It is able to do this because Ubiquiti caches all debian package installs on the UDM in /mnt/data, then re-installs them on every boot


### Compatibility
1. Should work on any UDM/UDMPro after 1.6.3
2. Tested and confirmed on 1.6.6, 1.7.0, 1.7.2rc4, 1.7.3rc1

### Upgrade from earlier way
* As long as you didn't change the filenames, installing the deb package is all you need to do.  If you want to clean up beforehand anyways....
```
rm /etc/init.d/udm.sh
systemctl disable udmboot
rm /etc/systemd/system/udmboot.service
```
* The new package is exactly the old steps packaged in a debian package
* [dpkg-build-files](dpkg-build-files) contains the scripts that build the package (using dh_make and debuild) if you want to build it yourself / change it
* Built on Ubuntu-20.04 on Windows 10/WSL2

## Steps
1. Copy on_boot.sh and make on_boot.d and add scripts to on_boot.d
    ```shell script
    mkdir -p /mnt/data/on_boot.d
    vi /mnt/data/on_boot.sh
    chmod u+x /mnt/data/on_boot.sh
    ```
    Example: [on_boot.sh](examples/udm-files/on_boot.sh)

2. Get into the unifios shell on your udm
```shell script
unifi-os shell
```
3. Download the [udm-boot_1.0.0-1_all.deb](packages/udm-boot_1.0.0-1_all.deb) and install it and go back to the UDM
```shell script
curl -L https://raw.githubusercontent.com/boostchicken/udm-utilities/master/on-boot-script/packages/udm-boot_1.0.0-1_all.deb -o udm-boot_1.0.0-1_all.deb
dpkg -i udm-boot_1.0.0-1_all.deb
exit
```
4. Copy any shell scripts you want to run to /mnt/data/on_boot.d and make sure they are executable and have the correct shebang (#!/bin/sh)
    Examples: 
    * Start a DNS Container [10-dns.sh](../dns-common/on_boot.d/10-dns.sh)
    * Start wpa_supplicant [on_boot.d/10-wpa_supplicant.sh](examples/udm-files/on_boot.d/10-start-containers.sh)
   