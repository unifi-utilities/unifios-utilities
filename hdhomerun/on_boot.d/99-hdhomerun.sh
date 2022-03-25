#!/bin/sh
# Place cross compiled version of `socat` in /mnt/data/hdhomerun
HDHOMERUN_IP=10.10.30.146

/mnt/data/hdhomerun/socat -d -d -v udp4-recvfrom:65001,broadcast,fork udp4-sendto:$HDHOMERUN_IP:65001 &
