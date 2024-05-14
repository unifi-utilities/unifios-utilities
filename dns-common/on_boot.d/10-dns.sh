#!/bin/bash
# Get DataDir location
DATA_DIR="/data"
case "$(ubnt-device-info firmware || true)" in
1*)
    DATA_DIR="/mnt/data"
    ;;
2* | 3* | 4*)
    DATA_DIR="/data"
    ;;
*)
    echo "ERROR: No persistent storage found." 1>&2
    exit 1
    ;;
esac 
## configuration variables:
VLAN=5
IPV4_IP="10.0.5.3"
# This is the IP address of the container. You may want to set it to match
# your own network structure such as 192.168.5.3 or similar.
IPV4_GW="10.0.5.1/24"
# As above, this should match the gateway of the VLAN for the container
# network as above which is usually the .1/24 range of the IPV4_IP

# if you want IPv6 support, generate a ULA, select an IP for the dns server
# and an appropriate gateway address on the same /64 network. Make sure that
# the 20-dns.conflist is updated appropriately. It will need the IP and GW
# added along with a ::/0 route. Also make sure that additional --dns options
# are passed to podman with your IPv6 DNS IPs when deploying the container for
# the first time. You will also need to configure your VLAN to have a static
# IPv6 block.

# IPv6 Also works with Prefix Delegation from your provider. The gateway is the
# IP of br(VLAN) and you can pick any ip address within that subnet that dhcpv6
# isn't serving
IPV6_IP=""
IPV6_GW=""

# set this to the interface(s) on which you want DNS TCP/UDP port 53 traffic
# re-routed through the DNS container. separate interfaces with spaces.
# e.g. "br0" or "br0 br1" etc.
FORCED_INTFC=""

# container name; e.g. nextdns, pihole, adguardhome, etc.
CONTAINER=pihole

if ! test -f /opt/cni/bin/macvlan; then
  echo "Error: CNI plugins not found. You can install it with the following command:" >&2
  echo "       curl -fsSLo ${DATA_DIR}/on_boot.d/05-install-cni-plugins.sh https://raw.githubusercontent.com/unifi-utilities/unifios-utilities/main/cni-plugins/05-install-cni-plugins.sh && /bin/sh ${DATA_DIR}/on_boot.d/05-install-cni-plugins.sh" >&2
  exit 1
fi

# set VLAN bridge promiscuous
ip link set "br${VLAN}" promisc on

# create macvlan bridge and add IPv4 IP
ip link add "br${VLAN}.mac" link "br${VLAN}" type macvlan mode bridge
ip addr add "${IPV4_GW}" dev "br${VLAN}.mac" noprefixroute

# (optional) add IPv6 IP to VLAN bridge macvlan bridge
if [ -n "${IPV6_GW}" ]; then
  ip -6 addr add "${IPV6_GW}" dev "br${VLAN}.mac" noprefixroute
fi

# set macvlan bridge promiscuous and bring it up
ip link set "br${VLAN}.mac" promisc on
ip link set "br${VLAN}.mac" up

# add IPv4 route to DNS container
ip route add "${IPV4_IP}/32" dev "br${VLAN}.mac"

# (optional) add IPv6 route to DNS container
if [ -n "${IPV6_IP}" ]; then
  ip -6 route add "${IPV6_IP}/128" dev "br${VLAN}.mac"
fi

# Make DNSMasq listen to the container network for split horizon or conditional forwarding
if ! grep -qxF "interface=br${VLAN}.mac" /run/dnsmasq.conf.d/custom.conf; then
  echo "interface=br${VLAN}.mac" >>/run/dnsmasq.conf.d/custom.conf
  kill -9 "$(cat /run/dnsmasq.pid)"
fi

if podman container exists "${CONTAINER}"; then
  podman start "${CONTAINER}"
else
  logger -s -t podman-dns -p "ERROR Container ${CONTAINER} not found, make sure you set the proper name, you can ignore this error if it is your first time setting it up"
fi

# (optional) IPv4 force DNS (TCP/UDP 53) through DNS container
for intfc in ${FORCED_INTFC}; do
  if [ -d "/sys/class/net/${intfc}" ]; then
    for proto in udp tcp; do
      prerouting_rule="PREROUTING -i ${intfc} -p ${proto} ! -s ${IPV4_IP} ! -d ${IPV4_IP} --dport 53 -j LOG --log-prefix [DNAT-${intfc}-${proto}]"
      iptables -t nat -C ${prerouting_rule} 2>/dev/null || iptables -t nat -A ${prerouting_rule}
      prerouting_rule="PREROUTING -i ${intfc} -p ${proto} ! -s ${IPV4_IP} ! -d ${IPV4_IP} --dport 53 -j DNAT --to ${IPV4_IP}"
      iptables -t nat -C ${prerouting_rule} 2>/dev/null || iptables -t nat -A ${prerouting_rule}

      # (optional) IPv6 force DNS (TCP/UDP 53) through DNS container
      if [ -n "${IPV6_IP}" ]; then
        prerouting_rule="PREROUTING -i ${intfc} -p ${proto} ! -s ${IPV6_IP} ! -d ${IPV6_IP} --dport 53 -j LOG --log-prefix [DNAT-${intfc}-${proto}]"
        ip6tables -t nat -C ${prerouting_rule} 2>/dev/null || ip6tables -t nat -A ${prerouting_rule}
        prerouting_rule="PREROUTING -i ${intfc} -p ${proto} ! -s ${IPV6_IP} ! -d ${IPV6_IP} --dport 53 -j DNAT --to ${IPV6_IP}"
        ip6tables -t nat -C ${prerouting_rule} 2>/dev/null || ip6tables -t nat -A ${prerouting_rule}
      fi
    done
  fi
done
