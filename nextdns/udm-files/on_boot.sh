#!/bin/sh

mkdir -p /opt/cni
ln -s /mnt/data/podman/cni/ /opt/cni/bin
ln -s /mnt/data/podman/cni/20-dns.conflist  /etc/cni/net.d/20-dns.conflist

# Assumes your Podman network made in the controller is on VLAN 5
# Adjust the IP to match the address in your cni configuration
ip link add br5.mac link br5 type macvlan mode bridge
ip link set br5 promisc on
ip link set br5.mac promisc on
ip addr add 10.0.5.2/24 dev br5.mac
ip link set br5.mac up
ip route add 10.0.5.3/32 dev br5.mac proto static scope link
podman start nextdns

# optional if you dont want to force everything through nextdns. also add anymore bridges for other networks (br5, 10 etc)
iptables -t nat -C PREROUTING -i br0 -p udp ! --source 10.0.5.3 ! --destination 10.0.5.3 --dport 53 -j DNAT --to 10.0.5.3 || iptables -t nat -A PREROUTING -i br0 -p udp ! --source 10.0.5.3 ! --destination 10.0.5.3 --dport 53 -j DNAT --to 10.0.5.3
iptables -t nat -C PREROUTING -i br0 -p tcp ! --source 10.0.5.3 ! --destination 10.0.5.3 --dport 53 -j DNAT --to 10.0.5.3 || iptables -t nat -A PREROUTING -i br0 -p tcp ! --source 10.0.5.3 ! --destination 10.0.5.3 --dport 53 -j DNAT --to 10.0.5.3
iptables -t nat -C POSTROUTING -o br0 -d 10.0.5.3 -p tcp --dport 53 -j MASQUERADE || iptables -t nat -A POSTROUTING -o br0  -d 10.0.5.3 -p tcp --dport 53 -j MASQUERADE
iptables -t nat -C POSTROUTING -o br0 -d 10.0.5.3 -p udp --dport 53 -j MASQUERADE || iptables -t nat -A POSTROUTING -o br0  -d 10.0.5.3 -p udp --dport 53 -j MASQUERADE
