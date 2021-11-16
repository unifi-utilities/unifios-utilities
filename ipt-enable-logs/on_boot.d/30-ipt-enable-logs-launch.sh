#!/bin/sh

set -e

if ! iptables-save | grep -e '\-A UBIOS_.* \--log-prefix "\[' > /dev/null; then
  /mnt/data/scripts/ipt-enable-logs.sh | iptables-restore -c
else
  echo "iptables already contains USER log prefixes, ignoring."
fi
