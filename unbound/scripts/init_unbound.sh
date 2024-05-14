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
# init unbound container - quick and dirty for now
# no checks, no balances

echo "Creating links..."
# link the script to create an IP on the macvlan for unbound
ln -s ${DATA_DIR}/unbound/on_boot.d/11-unbound-macvlanip.sh ${DATA_DIR}/on_boot.d/11-unbound-macvlanip.sh

# configure either IPv4 only or IPv4 and IPv6 by uncommenting the proper line
#

# link the IPv4 configuration for CNI
# ln -s ${DATA_DIR}/unbound/cni_plugins/21-unbound.conflist /etc/cni/net.d/21-unbound.conflist

# link the IPv4 and IPv6 configuration for CNI
ln -s ${DATA_DIR}/unbound/cni_plugins/21-unboundipv6.conflist /etc/cni/net.d/21-unbound.conflist

# create the podman network unbound
echo "Creating podman network..."
podman network create unbound

# create the container IP
echo "Creating container IP..."
sh ${DATA_DIR}/on_boot.d/11-unbound-macvlanip.sh
