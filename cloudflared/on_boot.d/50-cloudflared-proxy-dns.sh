#!/bin/bash

BIND=127.0.0.53
PORT=53
UPSTREAM="https://1.1.1.1/dns-query https://1.0.0.1/dns-query"
BOOTSTRAP="https://162.159.36.1/dns-query https://162.159.46.1/dns-query https://[2606:4700:4700::1111]/dns-query https://[2606:4700:4700::1001]/dns-query"

# build argument set, modify this if you want additional customisation
ARGS="--metrics ${BIND}: --address ${BIND} --port ${PORT}"

for i in ${UPSTREAM} ; do
  ARGS="${ARGS} --upstream $i"
done

for i in ${BOOTSTRAP} ; do
  ARGS="${ARGS} --bootstrap $i"
done

# ensure this directory exists
mkdir -p --mode=0755 /usr/share/keyrings

if [ ! -f /usr/share/keyrings/cloudflare-main.gpg ] ; then
  curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
fi

if [ ! -f /etc/apt/sources.list.d/cloudflared.list ] ; then
  echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared bullseye main' | tee /etc/apt/sources.list.d/cloudflared.list
fi

dpkg -l | grep cloudflared 1>/dev/null 2>&1

apt update
if [ ${?} != 0 ] ; then
  # attempt to install
  apt install -y cloudflared || exit 1
else
  # attempt to upgrade
  apt upgrade -y cloudflared
fi

systemctl stop cloudflared-proxy-dns.service
systemctl disable cloudflared-proxy-dns.service
rm -fv /etc/systemd/system/cloudflared-proxy-dns.service
systemctl daemon-reload

# create a dummy interface that cloudflared can listen on, but which will be independent of any Unifi OS related interfaces, including lo which we can't use
ifconfig cloudflared 1>/dev/null 2>&1 || ip link add name cloudflared type dummy

# add our bind IP to the cloudflared interface
ip addr show dev cloudflared | grep ${BIND}/32 1>/dev/null 2>&1 || ip addr add ${BIND}/32 dev cloudflared

tee /etc/systemd/system/cloudflared-proxy-dns.service >/dev/null <<EOF
[Unit]
Description=DNS over HTTPS (DoH) proxy client
Wants=network-online.target nss-lookup.target
Before=nss-lookup.target

[Service]
AmbientCapabilities=CAP_NET_BIND_SERVICE
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
DynamicUser=yes
ExecStart=/usr/bin/cloudflared proxy-dns ${ARGS}

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable cloudflared-proxy-dns.service
systemctl restart cloudflared-proxy-dns.service

# start the updating service to auto-update the package periodically
test -f /etc/systemd/system/cloudflared-update.timer && systemctl enable cloudflared-update.timer

# EOF
