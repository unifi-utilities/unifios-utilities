# UDM / UDMPro Boot Script
### Features
1. Allows you to run a shell script at S95 anytime your UDM starts / reboots
1. Persists through reboot
1. Must be re-done after firmware updates

### Compatibility
1. Should work on any UDM/UDMPro after 1.6.3
2. Tested and confirmed on 1.6.6, 1.7.0, 1.7.2rc4, 1.7.3rc1

## Steps

### Automated Setup

1. Copy [install.sh](install.sh) to your UDM and execute it
1. Copy any shell scripts you want to run to /mnt/data/on_boot.d and make sure they are executable and have the correct shebang (#!/bin/sh)
    Examples: 
    * Start a DNS Container [10-dns.sh](../dns-common/on_boot.d/10-dns.sh)
    * Start wpa_supplicant [on_boot.d/10-wpa_supplicant.sh](examples/udm-files/on_boot.d/10-wpa_supplicant.sh)

### Manual Setup

1. Copy on_boot.sh and make on_boot.d and add scripts to on_boot.d
    ```shell script
    mkdir -p /mnt/data/on_boot.d
    vi /mnt/data/on_boot.sh 
    chmod u+x /mnt/data/on_boot.sh
    ```
    Example: [on_boot.sh](examples/udm-files/on_boot.sh)

1. Enter the container shell
    ```shell script 
    unifi-os shell
    ```
1. make a script that sshs to the udm and runs on our boot script. 127.0.1.1 always points to the UDM
    ```shell script 
    echo "#!/bin/sh
    ssh -o StrictHostKeyChecking=no root@127.0.1.1 '/mnt/data/on_boot.sh'" > /etc/init.d/udm.sh
    chmod u+x /etc/init.d/udm.sh
    ```
    Example: [udm.sh](examples/unifi-os-files/udm.sh)
1. make a service that runs on startup, after we have networking
    ```shell script 
    echo "[Unit]
    Description=Run On Startup UDM
    After=network.target
    
    [Service]
    ExecStart=/etc/init.d/udm.sh
    
    [Install]
    WantedBy=multi-user.target" > /etc/systemd/system/udmboot.service
    ```
    Example: [udmboot.service](examples/unifi-os-files/udmboot.service)

1. enable it and test
    ```shell script 
    systemctl enable udmboot
    systemctl start udmboot
    ```
1. back to the udm
    ```shell script 
    exit
    ```
1. reboot your udm/udmpro and make sure it worked
    ```shell script
    reboot
    exit
    ```
