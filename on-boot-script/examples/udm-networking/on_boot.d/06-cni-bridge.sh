#!/bin/sh

## Create network bridge for CNI

ip link show cni0 > /dev/null 2>&1
if [ $? -ne 0 ]; then
    ip link add cni0 type bridge
fi
