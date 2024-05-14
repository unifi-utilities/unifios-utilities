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
if [ ! -d "${DATA_DIR}/on_boot.d" ]; then
  # If it does not exist, create the directory
  mkdir -p "${DATA_DIR}/on_boot.d"
  echo "Directory '${DATA_DIR}/on_boot.d' created."
else
  # If it already exists, print a message
  echo "Directory '${DATA_DIR}/on_boot.d' already exists. Moving on."
fi
set -e

if [ -f ${DATA_DIR}/on_boot.d/10-dns.sh ]; then
  if ! iptables-save | grep -e '\-A PREROUTING.* \--log-prefix "\[' >/dev/null; then
    ${DATA_DIR}/on_boot.d/10-dns.sh
  else
    echo "iptables already contains DNAT log prefixes, ignoring."
  fi
fi

${DATA_DIR}/on_boot.d/30-ipt-enable-logs-launch.sh
