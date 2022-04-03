# Running `unbound` on the UDM/P

This example is "ready to run" out of the box, if you've already installed Pi-hole on your UDM/P. Adjust the MAC and IP addresses if necessary.

## Prerequisites

Finish setup of [on_boot.d](../on-boot-script/) and [dns-common](../dns-common).

### Create another `podman` network

`unbound` will run on a different IP address to avoid any collisions.

In the current examples, the DNS resolver (e.g., pi-hole) is listening on `10.0.5.2`. The example will make `unbound` listen on `10.0.5.3`.

Follow the steps in [run-pihole](../run-pihole) to create a separate IP address, by coying the files in this directory to UDM/P.

* [11-unbound.sh](./on_boot.d/11-unbound.sh) -> `ln -s /mnt/data/on_boot.d/11-unbound.sh /mnt/data/unbound/on_boot.d/11-unbound.sh`
* IPv4 only: [21-unbound.conflist](./cni_plugins/21-unbound.conflist) -> `ln -s /mnt/data/podman/cni/21-unbound.conflist /mnt/data/unbound/cni_plugins/21-unbound.conflist` *or*
* IPv4 and IPv6: [21-unboundipv6.conflist](./cni_plugins/21-unboundipv6.conflist) -> `ln -s /mnt/data/podman/cni/21-unbound.conflist /mnt/data/unbound/cni_plugins/21-unbound.conflist`

Then, run

```bash
podman network create unbound
sh ../on_boot.d/11-unbound.sh
```

The error - if it's the first time you run it - can be ignored.

## Run the container for the first time

Run the script to start the container.

```bash
sh ./scripts/upd_unbound.sh
```

## Using unbound as upstream server for Pi-hole

Two things are left to do: set the upstream server and de-activate caching in Pi-hole.

To use `unbound` as the upstream server for Pi-hole, change the following settings in Pi-hole's admin interface:

* Settings -> DNS -> Upstream DNS Servers
  * Custom 1 (IPv4): 10.0.5.3 (or the IPv4 address you chose)
  * Custom 2 (IPv6): fdca:5c13:1fb8::3 (or the IPv6 address you chose)

Both Pi-hole as well as `unbound` are caching their requests. To make the changes of your upstream DNS and to de-activate caching in Pi-hole permanent, modify your `podman run` command **for pi-hole** in this way:

```sh
podman run -d --network dns --restart always \
    --name pihole \
    -e TZ="Europe/Berlin" \
    -v "/mnt/data/pihole/etc-pihole/:/etc/pihole/" \
    -v "/mnt/data/pihole/etc-dnsmasq.d/:/etc/dnsmasq.d/" \
    --dns=127.0.0.1 \
    --dns=10.0.5.3 \
    --hostname pi.hole \
    -e VIRTUAL_HOST="pi.hole" \
    -e PROXY_LOCATION="pi.hole" \
    -e PIHOLE_DNS_="10.0.5.3" \
    -e CUSTOM_CACHE_SIZE=0 \
    -e FTLCONF_REPLY_ADDR4="10.0.5.2" \
    -e FTLCONF_REPLY_ADDR6="fdca:5c13:1fb8::2" \
    -e IPv6="False" \
    pihole/pihole:latest
```

Again, replace the IPv4 and IPv6 addresses if you deviate from this example.

## Checking the configuration

To see if everything is configured properly, run the commands:

```bash
dig A doubleclick.net @10.0.5.2 +short
0.0.0.0
dig AAAA doubleclick.net @192.168.4.2 +short
::

dig A doubleclick.net @10.0.5.3 +short
142.251.37.14
dig AAAA doubleclick.net @192.168.4.3 +short
2a00:1450:4016:80b::200e
```

The first two commands query Pi-hole and do not return a valid IP address - as intended. The two following queries ask `unbound` and return valid IP addresses.

## Container image

This container is based on `klutchell/unbound`.

[Docker Hub](https://hub.docker.com/r/klutchell/unbound)
[Github](https://github.com/klutchell/unbound-docker)
