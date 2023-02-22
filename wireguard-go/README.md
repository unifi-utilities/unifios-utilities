# Wireguard VPN server / client

## Features

1. Wireguard VPN to anywhere! Uses wireguard-go, not the kernel module
1. Persists through reboots and firmware updates
1. Tested with a Wireguard Server in AWS

## Requirements

1. You have successfully setup the on boot script described [here](https://github.com/unifi-utilities/unifios-utilities/tree/main/on-boot-script)
1. Not recommended for Wireguard newbies. Set it up on other devices first. This document does not include iptables / nat rules

## Customization

- Update [wg0.conf](configs/wg0.conf) to match your environment
- You can use a custom interface name by changing wg0.conf to whatever you like
- Use PostUp and PostDown in your wg.conf to execute any commands after the interface is created or destroyed

## Steps

1. Make a directory for your keys and configuration:

   ```sh
   mkdir -p /data/wireguard
   ```

2. Create your public and private keys:

   ```sh
   podman run -i --rm --net=host --name wireguard_conf masipcat/wireguard-go wg genkey > /data/wireguard/privatekey
   podman run -i --rm --net=host --name wireguard_conf masipcat/wireguard-go wg pubkey < /data/wireguard/privatekey > /data/wireguard/publickey
   ```

3. Create a [Wireguard configuration](configs/wg0.conf) in /data/wireguard
4. Copy [20-wireguard.sh](on_boot.d/20-wireguard.sh) to /data/on_boot.d and update its values to reflect your environment
5. Execute /data/on_boot.d/[20-wireguard.sh](on_boot.d/20-wireguard.sh)
6. If you are running a server, make the appropriate firewall rules / port forwards
7. Execute the wg command in the container to verify the tunnel is up. It should look something like this:

   ```sh
   $ podman exec -it wireguard wg
   interface: wg0
       public key: <your public key here>
       private key: (hidden)
       listening port: 54321

   peer: <your peers public key>
       endpoint: 10.0.0.2:54321
       allowed ips: 10.1.0.0/16, 10.2.0.0/16
       latest handshake: 1 day, 14 hours, 46 minutes, 27 seconds ago
       transfer: 138.44 MiB received, 5.00 GiB sent
   ```

### Useful commands

```sh
# See interface status, see your public key
podman exec -it wireguard wg
# Bring up wg0
podman exec -it wireguard wg-quick up wg0
# Bring down wg0
podman exec -it wireguard wg-quick down wg0
```
