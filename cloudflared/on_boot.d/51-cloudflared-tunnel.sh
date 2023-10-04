#!/bin/bash

# this should be the secret tunnel token
SERVICE_TOKEN="YOUR SECRET TOKEN GOES HERE"

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

# only install/overwrite service automatically if the file does not yet exist
# this allows you to customise the service and how it operates if necessary
test -f /etc/systemd/system/cloudflared.service || cloudflared service install "${SERVICE_TOKEN}"

systemctl daemon-reload
systemctl enable cloudflared.service
systemctl restart cloudflared.service

# start the updating service to auto-update the package periodically
test -f /etc/systemd/system/cloudflared-update.timer && systemctl enable cloudflared-update.timer

# EOF
