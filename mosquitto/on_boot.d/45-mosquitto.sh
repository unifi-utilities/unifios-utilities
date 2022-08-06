#!/bin/sh

## network configuration
VLAN_ID=20
IPV4_IP_CONTAINER="10.0.20.4"
IPV4_IP_GATEWAY="10.0.20.1"
CONTAINER_NAME="mosquitto"
CONTAINER_CNI_PATH="/mnt/data/podman/cni/45-mosquitto.conflist"

# make sure cni plugs are installed
if ! test -f /opt/cni/bin/macvlan; then
    echo "Error: CNI plugins not found. You can install it with the following command:" >&2
    echo "       curl -fsSLo /mnt/data/on_boot.d/05-install-cni-plugins.sh https://raw.githubusercontent.com/unifi-utilities/unifios-utilities/main/cni-plugins/05-install-cni-plugins.sh && /bin/sh /mnt/data/on_boot.d/05-install-cni-plugins.sh" >&2
    exit 1
fi

## network configuration and startup
if ! test -f $CONTAINER_CNI_PATH; then
  logger -s -t podman-mosquitto -p ERROR Container network configuration for $CONTAINER_NAME not found, make sure $CONTAINER_CNI_PATH exists
  exit 1
fi

# link the conflist into live directory
ln -fs "$CONTAINER_CNI_PATH" "/etc/cni/net.d/$(basename "$CONTAINER_CNI_PATH")"

# set VLAN_ID bridge promiscuous
ip link set br${VLAN_ID} promisc on

# create macvlan bridge and add IPv4 IP
ip link add br${VLAN_ID}.mac link br${VLAN_ID} type macvlan mode bridge
ip addr add ${IPV4_IP_GATEWAY}/24 dev br${VLAN_ID}.mac noprefixroute

# set macvlan bridge promiscuous and bring it up
ip link set br${VLAN_ID}.mac promisc on
ip link set br${VLAN_ID}.mac up

# add IPv4 route to container
ip route add ${IPV4_IP_CONTAINER}/32 dev br${VLAN_ID}.mac

# create basic config if not exist
if ! test -f /mnt/data/mosquitto/config/mosquitto.conf; then
  mkdir -p /mnt/data/mosquitto/data /mnt/data/mosquitto/config
  cat > /mnt/data/mosquitto/config/mosquitto.conf<< EOF
listener 1883
allow_anonymous true

connection_messages true

persistence true
persistence_location /mosquitto/data/

log_dest stdout
log_type debug
log_timestamp true
EOF
fi


if podman container exists ${CONTAINER_NAME}; then
  podman start ${CONTAINER_NAME}
else
  logger -s -t podman-mosquitto -p ERROR Container $CONTAINER_NAME not found, make sure you set the proper name, you can ignore this error if it is your first time setting it up
fi

