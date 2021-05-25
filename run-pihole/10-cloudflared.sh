#!/bin/bash

if ! test -f /opt/cni/bin/macvlan; then
  ARCH=$(uname -m)
  if [ $ARCH == "x86_64" ]
  then
    ARCH="amd64"
  elif [ $ARCH == "aarch64" ]; then
      ARCH="arm64"
  fi
  curl -fsSLo "/opt/cloudflared" https://github.com/cloudflare/cloudflared/releases/download/2021.5.9/cloudflared-linux-$ARCH
  chmod +x /opt/cloudflared
fi
/opt/cloudflared update
/opt/cloudflared proxy-dns $CLOUDFLARED_OPTS &