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

## Manually Install Steps - Updated 2024-05-15

1. SSH into your udm

2. Download udm boot package and install it.

   ```bash
   curl -L https://github.com/unifi-utilities/unifios-utilities/raw/main/on-boot-script-2.x/packages/udm-boot-2x_1.0.1_all.deb -o udm-boot-2x_1.0.1_all.deb
   dpkg -i udm-boot-2x_1.0.1_all.deb
   systemctl daemon-reload
   systemctl enable udm-boot
   ```
3. Start the service (this will create the /data/on_boot.d directory if it does not already exist)
   ```
   systemctl start udm-boot
   ```

4. Copy any scripts you want to run to the /data/on_boot.d directory. 
Files here will be executed in a sorted order. Scripts with the X flag set will be executed, scripts without the X flag but ending in `.sh` will be sourced. 
All other files will be ignored.

   Examples:

   - Start a DNS Container [10-dns.sh](../dns-common/on_boot.d/10-dns.sh)
   - Start wpa_supplicant [on_boot.d/10-wpa_supplicant.sh](examples/udm-files/on_boot.d/10-wpa_supplicant.sh)
   - Add a persistent ssh key for the root user [on_boot.d/15-add-root-ssh-keys.sh](examples/udm-files/on_boot.d/15-add-root-ssh-keys.sh)

## Version History

### 1.0.0

- First release that persists through firmware
