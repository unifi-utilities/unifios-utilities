# Wireguard VPN server / client

### Features
1. Wireguard VPN to anywhere! Uses wireguard-go, not the kernel module.
1. Persists through reboots and firmware updates.
1. Tested with a Wireguard Server in AWS.

### Requirements
1. You have successfully setup the on boot script described [here](https://github.com/boostchicken/udm-utilities/tree/master/on-boot-script)
1. Not recommended for Wireguard newbies. Set it up on other devices first. This document does not include iptables / nat rules.

### Customization
* Update [wg0.conf](configs/wg0.conf) to match your env

### Steps
1. Create your public and private keys
    ```shell script
    podman run -i --rm --net=host --name wireguard_conf masipcat/wireguard-go wg genkey > /mnt/data/wireguard/privatekey
    podman run -i --rm --net=host --name wireguard_conf masipcat/wireguard-go wg genkey < /mnt/data/wireguard/privatekey > /mnt/data/wireguard/publickey
    ```
1. Make configurations dir
    ```shell script
    mkdir -p /mnt/data/wireguard
    ```
1. Create wireguard configuration file in /mnt/data/wireguard.  Template: [wg0.conf](configs/wg0.conf)    
1. Copy [20-wireguard.sh](on_boot.d/20-wireguard.sh) to /mnt/data/on_boot.d and update its values to reflect your environment
1. Execute /mnt/data/on_boot.d/20-wireguard.sh
1. If you are running a server, make the appropriate firewall rules / port forwards

### Useful commands
```shell script
podman exec -it wireguard wg
podman exec -it wireguard wg-quick up wg0
podman exec -it wireguard wg-quick down wg0
```

