#!/bin/bash

ARCH=$(uname -m)
if [ $ARCH == "x86_64" ]
then
  ARCH="amd64"
elif [ $ARCH == "aarch64" ]; then
    ARCH="arm64"
fi
curl -fsSLo "/opt/cloudflared" https://github.com/cloudflare/cloudflared/releases/download/2021.5.9/cloudflared-linux-$ARCH
chmod +x /opt/cloudflared

/opt/cloudflared update
/opt/cloudflared proxy-dns $CLOUDFLARED_OPTS &
