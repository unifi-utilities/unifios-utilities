# Run NextDNS on your UDM

# THIS IS NO LONGER MAINTAINED. VENDOR PROVIDES DIRECT SUPPORT

## Features

1. Run NextDNS on your UDM with a completely isolated network stack. This will not port conflict or be influenced by any changes on by Ubiquiti.
2. Resolves IP addresses handed out by DHCP on the UDM!
3. Persists through reboots and firmware updates.
4. If you are already using PiHole and want to test NextDNS out, you can just stop your PiHole container and start this one in its place using the same IP/CNI config.

## Requirements

1. You have already setup the on boot script described [here](https://github.com/unifi-utilities/unifios-utilities/tree/main/on-boot-script)

## Customization

- Feel free to change [20-dns.conflist](../cni-plugins/20-dns.conflist) to change the IP and MAC address of the container.
- The NextDNS docker image is not supported by NextDNS. It is built out of this repo. If you make any enhancements please contribute back via a Pull Request.
- If you want to inject custom DNS names into NextDNS use --add-host docker commands. The /etc/resolv.conf and /etc/hosts is generated from that and --dns.
- Edit [10-dns.sh](../dns-common/on_boot.d/10-dns.sh) and update its values to reflect your environment (specifically the container name)
- If you want IPv6 support use [20-dnsipv6.conflist](../cni-plugins/20-dnsipv6.conflist) and update [10-dns.sh](../dns-common/on_boot.d/10-dns.sh) with the IPv6 addresses. Also, please provide IPv6 servers to podman using --dns arguments.

## Docker

The official repo is boostchicken/nextdns. Latest will always refer to the latest builds, there are also tags for each NextDNS release (e.g. 1.6.4).

The Dockerfile is included, you can build it locally on your UDM if you don't want to pull from Docker Hub or make customizations

```sh
podman build . -t nextdns:latest
```

Building from another device is possible. You must have [buildx](https://github.com/docker/buildx/) installed to do cross platform builds. This is useful if you want to mirror to a private repo

```sh
docker buildx build --platform linux/arm64/v8 -t nextdns:latest .
```

## Steps

If you have already installed PiHole, skip right to step 5.

1. Copy [05-install-cni-plugins.sh](../cni-plugins/05-install-cni-plugins.sh) to /data/on_boot.d
1. Execute /data/on_boot.d/05-install-cni-plugins.sh
1. On your controller, make a Corporate network with no DHCP server and give it a VLAN. For this example we are using VLAN 5.
1. Copy [10-dns.sh](../dns-common/on_boot.d/10-dns.sh) to /data/on_boot.d and update its values to reflect your environment
1. Copy [20-dns.conflist](../cni-plugins/20-dns.conflist) to /data/podman/cni. This will create your podman macvlan network
1. Execute /data/on_boot.d/[10-dns.sh](../dns-common/on_boot.d/10-dns.sh)
1. Create /data/nextdns and copy [nextdns.conf](udm-files/nextdns.conf) to it.
1. Run the NextDNS docker container. Mounting dbus and running in privileged is only required for mDNS. Also, please change the --dns arguments to whatever was provided by NextDNS.

   ```sh
    podman run -d -it --privileged --network dns --restart always  \
       --name nextdns \
       -v "/data/nextdns/:/etc/nextdns/" \
       -v /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket \
       --mount type=bind,source=/config/dnsmasq.lease,target=/tmp/dnsmasq.leases \
       --dns=45.90.28.163 --dns=45.90.30.163 \
       --hostname nextdns \
       boostchicken/nextdns:latest
   ```

1. Update your DNS Servers to 10.0.5.3 (or your custom ip) in all your DHCP configs.
