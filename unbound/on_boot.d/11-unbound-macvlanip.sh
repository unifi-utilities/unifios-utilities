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
# Check if the directory exists
if [ ! -d "${DATA_DIR}/unbound" ]; then
  # If it does not exist, create the directory
  mkdir -p "${DATA_DIR}/unbound"
  mkdir -p "${DATA_DIR}/unbound.conf.d"
  echo "Directory '${DATA_DIR}/unbound' created."
else
  # If it already exists, print a message
  echo "Directory '${DATA_DIR}/unbound' already exists. Moving on."
fi

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
IPV6_IP="fdca:5c13:1fb8::3"
IPV6_GW="fdca:5c13:1fb8::1/64"

# to deactivate IPv6, uncomment lines below and comment out the lines above
#IPV6_IP=""
#IPV6_GW=""

# container name:unbound
CONTAINER=unbound

if ! test -f /opt/cni/bin/macvlan; then
  echo "Error: CNI plugins not found. You can install it with the following command:" >&2
  echo "       curl -fsSLo ${DATA_DIR}/on_boot.d/05-install-cni-plugins.sh https://raw.githubusercontent.com/unifi-utilities/unifios-utilities/main/cni-plugins/05-install-cni-plugins.sh && /bin/bash ${DATA_DIR}/on_boot.d/05-install-cni-plugins.sh" >&2
  exit 1
fi

# we assume that the VLAN bridge already exists, created by the filtering DNS (pi-hole) script
# add IPv4 IP
ip addr add "${IPV4_GW}" dev "br${VLAN}.mac" noprefixroute

# (optional) add IPv6 IP to VLAN bridge macvlan bridge
if [ -n "${IPV6_GW}" ]; then
  ip -6 addr add "${IPV6_GW}" dev "br${VLAN}.mac" noprefixroute
fi

# add IPv4 route to unbound container
ip route add "${IPV4_IP}/32" dev "br${VLAN}.mac"

# (optional) add IPv6 route to DNS container
if [ -n "${IPV6_IP}" ]; then
  ip -6 route add "${IPV6_IP}/128" dev "br${VLAN}.mac"
fi

if podman container exists "${CONTAINER}"; then
  podman start "${CONTAINER}"
else
  logger -s -t podman-unbound -p "ERROR Container ${CONTAINER} not found, make sure you set the proper name, you can ignore this error if it is your first time setting it up"
fi
