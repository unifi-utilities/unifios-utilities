#!/bin/bash
curl -L https://github.com/containernetworking/plugins/releases -o cni.tgz

mkdir -p /mnt/data/podman/cni/
tar xf cni.tgz /mnt/data/podman/cni/
