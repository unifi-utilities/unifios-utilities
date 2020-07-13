# Run PiHole on your UDM

## Features

1. Run PiHole on your UDM with a completely isolated network stack.  This will not port conflict or be influenced by any changes on by Ubiquiti
2. Persists through reboots and firmware updates.

## Requirements

1. You have successfully setup the on boot script described [here](https://github.com/boostchicken/udm-utilities/tree/master/on-boot-script)

## Customization

* Feel free to change [20-dns.conflist](../cni-plugins/20-dns.conflist) to change the IP address of the container.
* Update [10-dns.sh](../dns-common/on_boot.d/10-dns.sh) with your own values
* If you want IPv6 support use [20-dnsipv6.conflist](../cni-plugins/20-dnsipv6.conflist) and update [10-dns.sh](../dns-common/on_boot.d/10-dns.sh) with the IPv6 addresses. Also, please provide IPv6 servers to podman using --dns arguments.

## Steps

1. On your controller, make a Corporate network with no DHCP server and give it a VLAN. For this example we are using VLAN 5.
2. Copy [10-dns.sh](../dns-common/on_boot.d/10-dns.sh) to /mnt/data/on_boot.d and update its values to reflect your environment
3. Execute /mnt/data/on_boot.d/10-dns.sh
4. Copy [20-dns.conflist](../cni-plugins/20-dns.conflist) to /mnt/data/podman/cni.  This will create your podman macvlan network
5. Run the pihole docker container, be sure to make the directories for your persistent pihole configuration.  They are mounted as volumes in the command below.

    ```sh
     podman run -d --network dns --restart always \
        --name pihole \
        -e TZ="America/Los Angeles" \
        -v "/mnt/data/etc-pihole/:/etc/pihole/" \
        -v "/mnt/data/pihole/etc-dnsmasq.d/:/etc/dnsmasq.d/" \
        --dns=127.0.0.1 --dns=1.1.1.1 \
        --hostname pi.hole \
        -e VIRTUAL_HOST="pi.hole" \
        -e PROXY_LOCATION="pi.hole" \
        -e ServerIP="10.0.5.3" \
        -e IPv6="False" \
        pihole/pihole:latest
    ```

    The below errors are expected and acceptable

    ```sh
    ERRO[0022] unable to get systemd connection to add healthchecks: dial unix /run/systemd/private: connect: no such file or directory
    ERRO[0022] unable to get systemd connection to start healthchecks: dial unix /run/systemd/private: connect: no such file or directory
    ```

6. Set pihole password

    ```sh
    podman exec -it pihole pihole -a -p YOURNEWPASSHERE
    ```

7. Update your DNS Servers to 10.0.5.3 (or your custom ip) in all your DHCP configs.
8. Access the pihole like you would normally.
