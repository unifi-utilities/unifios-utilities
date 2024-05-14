#!/bin/bash
# Place cross compiled version of `socat` in /data/hdhomerun
HDHOMERUN_IP=10.10.30.146

# Get DataDir location
DATA_DIR="/data"
case "$(ubnt-device-info firmware || true)" in
1*)
    DATA_DIR="/mnt/data"
    ;;
2* | 3* | 4*)
    DATA_DIR="/data"
    ;;
*)
    echo "ERROR: No persistent storage found." 1>&2
    exit 1
    ;;
esac
# Check if the directory exists
if [ ! -d "$DATA_DIR" ]; then
    # If it does not exist, create the directory
    mkdir -p "$DATA_DIR"
    echo "Directory '$DATA_DIR' created."
else
    # If it already exists, print a message
    echo "Directory '$DATA_DIR' already exists. Moving on."
fi

${DATA_DIR}/hdhomerun/socat -d -d -v udp4-recvfrom:65001,broadcast,fork udp4-sendto:$HDHOMERUN_IP:65001 &
