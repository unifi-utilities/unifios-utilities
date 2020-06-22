#!/bin/sh

curl -L https://github.com/containernetworking/plugins/releases/download/v0.8.6/cni-plugins-linux-arm64-v0.8.6.tgz -o /tmp/cni.tgz
mkdir -p /mnt/data/podman/cni/
tar xf /tmp/cni.tgz -C /mnt/data/podman/cni/
rm /tmp/cni.tgz
