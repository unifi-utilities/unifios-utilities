#!/bin/sh

mkdir -p /opt/cni
ln -s /mnt/data/podman/cni/ /opt/cni/bin
ln -s /mnt/data/podman/cni/20-dns.conflist  /etc/cni/net.d/20-dns.conflist

# Assumes your Podman network made in the controller is on VLAN 5
# Adjust the IP to match the address in your cni configuration
ip link add br5.mac link br5 type macvlan mode bridge
ip addr add 10.0.5.2/24 dev br5.mac
ip link set br5.mac up
ip route add 10.0.5.3/32 dev br5.mac proto static scope link
podman start nextdns
