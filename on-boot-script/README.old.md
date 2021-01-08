# Legacy setup

## Automated Setup

* NB! THESE WILL NOT PERSIST THROUGH FIRMWARE. They still work however

1. Copy [install.sh](manual-install/install.sh) to your UDM and execute it
1. Copy any shell scripts you want to run to /mnt/data/on_boot.d and make sure they are executable and have the correct shebang (#!/bin/sh)
    Examples:
    * Start a DNS Container [10-dns.sh](../dns-common/on_boot.d/10-dns.sh)
    * Start wpa_supplicant [on_boot.d/10-wpa_supplicant.sh](examples/udm-files/on_boot.d/10-start-containers.sh)

## Manual Setup

1. Copy on_boot.sh and make on_boot.d and add scripts to on_boot.d

    ```sh
    mkdir -p /mnt/data/on_boot.d
    vi /mnt/data/on_boot.sh
    chmod u+x /mnt/data/on_boot.sh
    ```

    Example: [on_boot.sh](examples/udm-files/on_boot.sh)

2. Enter the container shell

    ```sh
    unifi-os shell
    ```

3. make a script that sshs to the udm and runs on our boot script. 127.0.1.1 always points to the UDM

    ```sh
    echo "#!/bin/sh
    ssh -o StrictHostKeyChecking=no root@127.0.1.1 '/mnt/data/on_boot.sh'" > /etc/init.d/udm.sh
    chmod u+x /etc/init.d/udm.sh
    ```

    Example: [udm.sh](examples/unifi-os-files/udm.sh)
4. make a service that runs on startup, after we have networking

    ```sh
    echo "[Unit]
    Description=Run On Startup UDM
    After=network.target

    [Service]
    ExecStart=/etc/init.d/udm.sh

    [Install]
    WantedBy=multi-user.target" > /etc/systemd/system/udmboot.service
    ```

    Example: [udmboot.service](examples/unifi-os-files/udmboot.service)

5. enable it and test

    ```sh
    systemctl enable --now udmboot
    ```

6. back to the udm

    ```sh
    exit
    ```

7. reboot your udm/udmpro and make sure it worked

    ```sh
    reboot
    exit
    ```
