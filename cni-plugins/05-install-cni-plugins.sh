#!/bin/sh

if test "$#" -eq 0; then
  set latest
fi

set "$(basename "$(curl -fsSLo /dev/null -w "%{url_effective}" https://github.com/containernetworking/plugins/releases/$1)")" "$@"

if ! test -f "/mnt/data/.cache/cni-plugins/cni-plugins-linux-arm64-$1.tgz"; then
  echo "Downloading https://github.com/containernetworking/plugins/releases/download/$1/cni-plugins-linux-arm64-$1.tgz"
  curl -fsSLo "/tmp/cni-plugins-linux-arm64-$1.tgz" "https://github.com/containernetworking/plugins/releases/download/$1/cni-plugins-linux-arm64-$1.tgz" \
    && mkdir -p "/mnt/data/.cache/cni-plugins" \
    && mv "/tmp/cni-plugins-linux-arm64-$1.tgz" "/mnt/data/.cache/cni-plugins/cni-plugins-linux-arm64-$1.tgz"
fi \
  && if [ "$1" != "$2" ]; then
    ln -sf "cni-plugins-linux-arm64-$1.tgz" "/mnt/data/.cache/cni-plugins/cni-plugins-linux-arm64-$2.tgz"
  fi

test -f "/mnt/data/.cache/cni-plugins/cni-plugins-linux-arm64-$2.tgz" \
  && echo "Pouring /mnt/data/.cache/cni-plugins/cni-plugins-linux-arm64-$2.tgz" \
  && rm -rf /opt/cni/bin \
  && mkdir -p /opt/cni/bin \
  && tar -xzC /opt/cni/bin -f "/mnt/data/.cache/cni-plugins/cni-plugins-linux-arm64-$2.tgz"
