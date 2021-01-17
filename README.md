# udm-utilities [![Slack](https://img.shields.io/badge/slack-boostchicken-blue.svg?logo=slack "Boostchicken Slack")](https://join.slack.com/t/boostchicken/shared_invite/zt-fcjszaw4-2ZuNFxIQnrpjxixnm17LXQ)

A collection of things to enhance the capabilities of your Unifi Dream Machine or Dream Machine Pro.

## Contributing

Pull Requests welcome! If you use this functionality to do new cool stuff to your UDM/P please send a PR and share it with the community!

## General Tools

### suricata
Run an updated version of suricata and apply custom rules that survive reboot 
### on-boot-script
Do this first. Enables init.d style scripts to run on every boot of your UDM. Includes examples to run wpa-supplicant/eap-proxy and/or ntop-ng on startup. Follow this [readme](https://github.com/boostchicken/udm-utilities/blob/master/on-boot-script/README.md).  
**It enables complete customization of your UDM/P and fills the gap that config.gateway.json left behind.**

### python

If you need python3 on your UDM, generally not recommended, can always use it in unifi-os container

## VPN Servers / Clients

### wireguard-go

Run a Wireguard client/server on your UDM/P.  Utilizes wireguard-go, not linux kernel modules.  The performance will take a hit due to that.

## DNS Providers
Install a DNS server that functions as a network-wide ad and tracker blocker, and which can also securely proxy encrypted DNS requests to an upstream DNS provider. Begin by following the instructions to setup [on-boot-script](https://github.com/boostchicken/udm-utilities/tree/master/on-boot-script) and [dns-common](https://github.com/boostchicken/udm-utilities/tree/master/dns-common/on_boot.d). Then, follow the guides below to setup either Pi-Hole, NextDNS, or AdGuard Home.

### dns-common
Base configuration for DNS server containers, both IPv4 and IPv6.  Utilizes MacVLAN CNI plugins to completely isolate the network stack.

### run-pihole

Run pihole on your UDM with podman.

### nextdns

Run NextDNS on your UDM with podman.

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

Provision and renew LetsEncrypt SSL certs from your UDM/P

### OpenConnect VPN
<https://github.com/shuguet/openconnect-udm>
OpenConnect VPN Client for the UniFi Dream Machine Pro (Unofficial)


### Unifi API Browser

https://hub.docker.com/r/scyto/unifibrowser

This is a docker container that implements <https://github.com/Art-of-WiFi/UniFi-API-browser> to provide a graphical tool to inspect the data structures available via the unifi API.  Great if you are using the REST API for your own puposes and want to explore. Works with multiple controler versions.
