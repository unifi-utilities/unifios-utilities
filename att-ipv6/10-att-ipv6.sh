#! /bin/bash
set -eo pipefail

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
if [ ! -d "$DATA_DIR/att-ipv6" ]; then
  # If it does not exist, create the directory
  mkdir -p "$DATA_DIR/att-ipv6"
  echo "Directory '$DATA_DIR/att-ipv6' created."
else
  # If it already exists, print a message
  echo "Directory '$DATA_DIR/att-ipv6' already exists. Moving on."
fi

wan_iface="eth8"                                     # "eth9" for UDM Pro WAN2
vlans="br0"                                          # "br0 br100 br101..."
domain="example.invalid"                             # DNS domain
dns6="[2001:4860:4860::8888],[2001:4860:4860::8844]" # Google

CONTAINER=att-ipv6
confdir=${DATA_DIR}/att-ipv6

# main
mkdir -p "${confdir}/dhcpcd"

test -f "${confdir}/dhcpcd.conf" || {
  : >"${confdir}/dhcpcd.conf.tmp"
  cat >>"${confdir}/dhcpcd.conf.tmp" <<EOF
allowinterfaces ${wan_iface}
nodev
noup
ipv6only
nooption domain_name_servers
nooption domain_name
duid
persistent
option rapid_commit
option interface_mtu
require dhcp_server_identifier
slaac private
noipv6rs

interface ${wan_iface}
  ipv6rs
  ia_na 0
EOF

  ix=0
  for vv in $vlans; do
    echo "  ia_pd ${ix} ${vv}/0"
    ix=$((ix + 1))
  done >>"${confdir}/dhcpcd.conf.tmp"
  mv "${confdir}/dhcpcd.conf.tmp" "${confdir}/dhcpcd.conf"
}

test -f "${confdir}/att-ipv6-dnsmasq.conf" || {
  : >"${confdir}/att-ipv6-dnsmasq.conf.tmp"
  cat >>"${confdir}/att-ipv6-dnsmasq.conf.tmp" <<EOF
#
# via att-ipv6
#
enable-ra
no-dhcp-interface=lo
no-ping
EOF

  for vv in $vlans; do
    cat <<EOF

interface=${vv}
dhcp-range=set:att-ipv6-${vv},::2,::7d1,constructor:${vv},slaac,ra-names,64,86400
dhcp-option=tag:att-ipv6-${vv},option6:dns-server,${dns6}
domain=${domain}|${vv}
ra-param=${vv},high,0
EOF
  done >>"${confdir}/att-ipv6-dnsmasq.conf.tmp"
  mv "${confdir}/att-ipv6-dnsmasq.conf.tmp" "${confdir}/att-ipv6-dnsmasq.conf"
}

if podman container exists "$CONTAINER"; then
  podman start "$CONTAINER"
else
  podman run -d --restart=always --name "$CONTAINER" -v "${confdir}/dhcpcd.conf:/etc/dhcpcd.conf" -v "${confdir}/dhcpcd:/var/lib/dhcpcd" --net=host --privileged ghcr.io/michaelw/dhcpcd
fi

# Fix DHCP, assumes DHCPv6 is turned off in UI
cp "${confdir}/att-ipv6-dnsmasq.conf" /run/dnsmasq.conf.d/
start-stop-daemon -K -q -x /usr/sbin/dnsmasq
