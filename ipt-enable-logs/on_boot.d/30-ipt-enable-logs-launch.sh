#!/bin/bash

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
if [ ! -d "${DATA_DIR}/scripts" ]; then
  # If it does not exist, create the directory
  mkdir -p "${DATA_DIR}/scripts"
  echo "Directory '${DATA_DIR}/scripts' created."
else
  # If it already exists, print a message
  echo "Directory '${DATA_DIR}/scripts' already exists. Moving on."
fi

set -e

if ! iptables-save | grep -e '\-A UBIOS_.* \--log-prefix "\[' >/dev/null; then
  ${DATA_DIR}/scripts/ipt-enable-logs.sh | iptables-restore -c
else
  echo "iptables already contains USER log prefixes, ignoring."
fi
