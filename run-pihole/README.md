# Run Pi-hole on your UDM

## Features

1. Run Pi-hole on your UDM with a completely isolated network stack. This will not port conflict or be influenced by any changes on by Ubiquiti
2. Persists through reboots and firmware updates.

## Requirements

1. You have successfully setup the on boot script described [here](https://github.com/unifi-utilities/unifios-utilities/tree/main/on-boot-script)

## Customizations

Note: IP and VLAN settings for you pihole network, 20-dns-conflist and 10-dns.sh MUST all match each other.

- Example settings for pihole network:
  Network Name: Pihole
  Host address: 10.0.5.1
  Netmask: 24
  VLAN ID: 5
  Network Type: Standard
  Multicast DNS: Enable
  DHCP: None
  Ipv6 Interface Type: None

- YOU WILL NEED TO CHANGE [`20-dns.conflist`](../cni-plugins/20-dns.conflist)
  Change the line:
  "mac": "add 3 fake hex portions, replacing x's here 00:1c:b4:xx:xx:xx",
  to create a legitimate mac address that matches some vendor space(first 6 digits ). It needs to be unique on your network.
  The example gives one option. Locally administered mac addresses do not work.

  If you are using a different IP address than the example:
  Change these lines to match your settings:
  "address": "10.0.5.3/24",
  "gateway": "10.0.5.1"
  If you are using a different VLAN than the example:
  Change this line to match your VLAN number:
  "master": "br5",

- You MAY need to change[`10-dns.sh`](../dns-common/on_boot.d/10-dns.sh).
  If you are using a different IP address than the example:
  Change these lines to match your settings:
  IPV4_IP="10.0.5.3"
  IPV4_GW="10.0.5.1/24"
  If you are using a different VLAN than the example:
  Change this line to match your VLAN number:
  VLAN=5
  If you want the pihole container to have a different name than the example:
  Change this line to match the different name:
  CONTAINER=pihole
- If you want IPv6 support
  Use 20-dnsipv6.conflist and update 10-dns.sh with the IPv6 addresses.
  Also, please provide IPv6 servers to podman using --dns arguments.

## Steps

### Configuration files and scripts

1.0 Copy [`05-install-cni-plugins.sh`](../cni-plugins/05-install-cni-plugins.sh) to `/data/on_boot.d`
1.1 Execute `chmod +x /data/on_boot.d/05-install-cni-plugins.sh`
1.2 Execute `/data/on_boot.d/05-install-cni-plugins.sh`

2.0 On your controller, create a network with no DHCP server and give it a VLAN.(see example settings above).
2.1 Copy YOUR modified [`20-dns.conflist`] to `/data/podman/cni`
2.2 Execute `chmod +x /data/podman/cni/20-dns.conflist`
2.3 Execute `cp /data/podman/cni/20-dns.conflist /etc/cni/net.d/dns.conflist`

    To check progress - run the command:
    ```shell
    podman network inspect dns
    ```
    You should see a copy of your 20-dns.conflist displayed.

3.0 Copy your [`10-dns.sh`] to `/data/on_boot.d`
3.1 Execute `chmod +x /data/on_boot.d/10-dns.sh`
3.2 Execute `/data/on_boot.d/10-dns.sh`

### Create directories for persistent Pi-hole configuration

4.0 Execute the following commands:

```sh
mkdir -p /data/etc-pihole
mkdir -p /data/pihole/etc-dnsmasq.d
```

### Create the pihole container

Note:
--name MUST match the name you set in 10-dns.sh
-e FTLCONF_REPLY_ADDR4 MUST be in the range you set for your pihole network
-e TZ MUST match the timezone for your controller

The example uses these upstream DNS servers The following command sets the upstream DNS servers to `1.1.1.1` ([Cloudflare DNS](https://1.1.1.1/)) and `8.8.8.8` ([Google DNS](https://developers.google.com/speed/public-dns/)).
If you want to use different upstream DNS servers, change the following lines:
--dns=1.1.1.1 \
 --dns=8.8.8.8 \

If you want to run a DHCP server as well you need to add the following lines:
--cap-add=NET_ADMIN
  
5.0 Run the following (or your modified version) by copy / pasting the entire set.

    ```sh
    podman run -d \
        --network dns \
        --restart always \
        --name pihole \
        -e TZ="America/Los Angeles" \
    --cap-add=NET_ADMIN \
        -v "/data/etc-pihole/:/etc/pihole/" \
        -v "/data/pihole/etc-dnsmasq.d/:/etc/dnsmasq.d/" \
        --dns=127.0.0.1 \
        --dns=1.1.1.1 \
        --dns=8.8.8.8 \
        --hostname pi.hole \
        -e VIRTUAL_HOST="pi.hole" \
        -e PROXY_LOCATION="pi.hole" \
        -e FTLCONF_REPLY_ADDR4="10.0.5.3" \
        -e IPv6="False" \
        pihole/pihole:latest
    ```

    The below errors are expected and acceptable:

    > ```
    > ERRO[0022] unable to get systemd connection to add healthchecks: dial unix /run/systemd/private: connect: no such file or directory
    > ERRO[0022] unable to get systemd connection to start healthchecks: dial unix /run/systemd/private: connect: no such file or directory
    > ```

6.0 Set the pihole admin password

    ```sh
    podman exec -it pihole pihole -a -p YOURNEWPASSHERE
    ```

## Set the new DNS in your UDM

7.0 Update your DNS Servers to `10.0.5.3` (or your custom ip) for each of your Networks (UDM GUI | Networks | Advanced | DHCP Name Server)
7.1 Access the pihole web interface like you would normally, e.g. http://10.0.5.3 if using the example

## Upgrading your PiHole container

1. Edit `upd_pihole.sh` script to use the same `podman run` command you used at installation.
2. Copy the `upd_pihole.sh` script to /data/scripts
3. Anytime you want to update your pihole installation, simply run `/data/scripts/upd_pihole.sh`

## Optional Builds

The cloudflared command is written in Go and is not very lightweight. In my
experience, it's not made for long-term running. Instead, the project DoTe
has a tiny memory footprint and operates on an event loop with some major
optimisations for connection caching. It allows you to forward traffic to any
DNS-over-TLS provider.

### PiHole with CloudFlareD Command

    podman run -d \
        --network dns
        --restart always \
        --name pihole \
        -e TZ="America/Los Angeles" \
        -v "/data/etc-pihole/:/etc/pihole/" \
        -v "/data/pihole/etc-dnsmasq.d/:/etc/dnsmasq.d/" \
        --dns=127.0.0.1 \
        --dns=1.1.1.1 \
        --hostname pi.hole \
        -e CLOUDFLARED_OPTS="--port 5053 --address 0.0.0.0" \
        -e VIRTUAL_HOST="pi.hole" \
        -e PROXY_LOCATION="pi.hole" \
        -e ServerIP="10.0.5.3" \
        -e PIHOLE_DNS_="127.0.0.1#5053" \
        -e IPv6="False" \
        boostchicken/pihole:latest

### PiHole with DoTe

Simply copy the `custom_pihole_dote.sh` script to `/data/scripts` and run it
to forward all DNS traffic over TLS to Cloudflare 1.1.1.1 / 1.0.0.1. You can modify the
script to forward to different services with ease and full configuration
options including certificate pinning is available in the DoTe README here:
https://github.com/chrisstaite/DoTe/

    podman run -d \
        --network dns \
        --restart always \
        --name pihole \
        -e TZ="America/Los Angeles" \
        -v "/data/etc-pihole/:/etc/pihole/" \
        -v "/data/pihole/etc-dnsmasq.d/:/etc/dnsmasq.d/" \
        --dns=127.0.0.1 \
        --dns=1.1.1.1 \
        --hostname pi.hole \
        -e CLOUDFLARED_OPTS="--port 5053 --address 0.0.0.0" \
        -e VIRTUAL_HOST="pi.hole" \
        -e PROXY_LOCATION="pi.hole" \
        -e ServerIP="10.0.5.3" \
        -e PIHOLE_DNS_="127.0.0.1#5053" \
        -e IPv6="False" \
        boostchicken/pihole-dote:latest


## New releases will be made when PiHole updates their labels
