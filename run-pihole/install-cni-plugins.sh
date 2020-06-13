#!/bin/sh
cd /tmp
curl -L https://github.com/containernetworking/plugins/releases/download/v0.8.6/cni-plugins-linux-arm64-v0.8.6.tgz -o cni.tgz

mkdir -p /mnt/data/podman/cni/
tar xf cni.tgz -C /mnt/data/podman/cni/
