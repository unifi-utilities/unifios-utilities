# udm-utilities [![Slack](https://img.shields.io/badge/slack-boostchicken-blue.svg?logo=slack "Boostchicken Slack")](https://join.slack.com/t/boostchicken/shared_invite/zt-fcjszaw4-2ZuNFxIQnrpjxixnm17LXQ) [![UDMP Podman](https://github.com/boostchicken/udm-utilities/actions/workflows/podman-udmp.yml/badge.svg)](https://github.com/boostchicken/udm-utilities/actions/workflows/podman-udmp.yml) [![UDMPSE Podman](https://github.com/boostchicken/udm-utilities/actions/workflows/podman-udmse.yml/badge.svg?branch=master)](https://github.com/boostchicken/udm-utilities/actions/workflows/podman-udmse.yml)

A collection of things to enhance the capabilities of your Unifi Dream Machine or Dream Machine Pro.

## Contributing

Pull Requests welcome! If you use this functionality to do new cool stuff to your UDM/P please send a PR and share it with the community!

## Custom Kernel

If you want to do a custom kernel with wireguard support, multicast, multipath routing that is now a possiblity.  Please see the repo and please use at your own risk. This a much larger change than anything in this repo.

[udm-kernel-tools](https://github.com/fabianishere/udm-kernel-tools)

## Custom Podman Builds for UDMP-SE

<https://github.com/boostchicken/udm-utilities/actions>

Extract the zip to the root of your device!
Look at the assets on the Podman workflow.

## General Tools

### on-boot-script

Do this first. Enables `init.d` style scripts to run on every boot of your UDM. Includes examples to run `wpa-supplicant/eap-proxy` and/or `ntop-ng` on startup. Follow this [readme](https://github.com/boostchicken/udm-utilities/blob/master/on-boot-script/README.md).

**It enables complete customization of your UDM/P and fills the gap that config.gateway.json left behind.**

### podman-update

Updates Podman, conmon, and runc to a recent version.  This allows docker-compose usage as well.

### container-common

Apply this after on-boot-script. Updates container defaults to maintain **stable disk usage footprint** of custom containers. **Prevents logs filling up UDM storage full**.

### python

If you need python3 on your UDM, generally not recommended, can always use it in unifi-os container.

## VPN Servers / Clients

### wireguard-go

Run a Wireguard client/server on your UDM/P.  Utilizes wireguard-go, not linux kernel modules.  The performance will take a hit due to that.

### WireGuard kernel module for UDM/P

<https://github.com/tusc/wireguard-kmod>

Uses a prebuilt linux kernel module, without the need to move to a custom kernel.

### OpenConnect VPN

<https://github.com/shuguet/openconnect-udm>

OpenConnect VPN Client for the UniFi Dream Machine Pro (Unofficial).

### split-vpn

<https://github.com/peacey/split-vpn>

A split tunnel VPN script for the UDM with policy based routing. This helper script can be used on your UDM to route select VLANs, clients, or even domains through a VPN connection. It supports OpenVPN, WireGuard, and OpenConnect (Cisco AnyConnect) clients running directly on your UDM, and external VPN clients running on other servers on your network.

## DNS Providers

Install a DNS server that functions as a network-wide ad and tracker blocker, and which can also securely proxy encrypted DNS requests to an upstream DNS provider. Begin by following the instructions to setup [on-boot-script](https://github.com/boostchicken/udm-utilities/tree/master/on-boot-script) and [dns-common](https://github.com/boostchicken/udm-utilities/tree/master/dns-common/on_boot.d). Then, follow the guides below to setup either Pi-Hole, NextDNS, or AdGuard Home.

### dns-common

Base configuration for DNS server containers, both IPv4 and IPv6.  Utilizes MacVLAN CNI plugins to completely isolate the network stack.

### run-pihole [![!Docker Pulls](https://img.shields.io/docker/pulls/boostchicken/pihole.svg?color=green&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=pulls&logo=docker)](https://hub.docker.com/u/boostchicken)

PiHole w/ DoH Image 
Run Pi-hole on your UDM with podman. Also contains custom image for Pi-hole with `cloudflared`.

### PiHole with DoTe  [![!Docker Pulls](https://img.shields.io/docker/pulls/boostchicken/pihole-dote.svg?color=green&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=pulls&logo=docker)](https://hub.docker.com/u/boostchicken)

Desigened by: <https://github.com/chrisstaite/DoTe/>

Alternative to mine which uses DoTe

### AdguardHome

Run AdguardHome on your UDM with podman.

### Cloudflare DDNS

Update your cloudflare domains from your UDM with podman.

## Cool projects you can use with this

### multicast-relay

<https://hub.docker.com/r/scyto/multicast-relay>

This is a docker container that implements <https://github.com/alsmith/multicast-relay> to provide mDNS and SSDP on a unifi dream machine. It will likely work on any multi homed host.

### ntopng

<https://github.com/tusc/ntopng-udm>

Much better network stats for your UDM/P!  Install this docker container and create an on_boot script to make sure it's always running.

### LetsEncrypt SSL Certs

<https://github.com/kchristensen/udm-le>

Provision and renew LetsEncrypt SSL certs from your UDM/P.

<https://github.com/alxwolf/ubios-cert>

Similar to `udm-le`, adding different providers for SSL/TLS certificates (LE, ZeroSSL, BuyPass) and DNS API (all-inkl.com) currently not supported by [LEGO]<https://go-acme.github.io/lego/dns/>.

### Unifi API Browser

<https://hub.docker.com/r/scyto/unifibrowser>

This is a docker container that implements <https://github.com/Art-of-WiFi/UniFi-API-browser> to provide a graphical tool to inspect the data structures available via the unifi API.  Great if you are using the REST API for your own purposes and want to explore. Works with multiple controller versions.

### Unifi UDM-Pro auto fan speed

<https://github.com/renedis/ubnt-auto-fan-speed>

A shell script with the goal to make the UDM-Pro silenced while still having good thermal values. It stops the build in service that monitors the thermal values, fan speed and connection of a HDD/SSD. After that it sets the thermal/fan chip (adt7475) to automatic mode. Once that is done it changes the thermal and fan values specified in the script.

### Jumbo Frames

<https://github.com/kalenarndt/udmp-jumbo-frames>

Make your Jumbo frames work!

### rclone

<https://rclone.org/>

Run rclone container with Web GUI for offsite backups.

## Unsupported / No longer maintained

### nextdns

Run NextDNS on your UDM with podman.

### suricata

Updates suricata to a recent version.
