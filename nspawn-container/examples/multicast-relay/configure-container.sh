#!/bin/bash

set -eux -o pipefail

# Install dependencies
apt install -y --no-install-recommends python3 python3-netifaces git ca-certificates

# Checkout latest commit of default branch of multicast-relay
cd /opt
git clone --depth=1 https://github.com/alsmith/multicast-relay.git

# Drop a startup script
cat <<'EOF' | tee /opt/multicast-relay/start.sh
#!/bin/dash
# This script adapted from scyto
# https://github.com/scyto/multicast-relay/blob/master/start.sh
SCRIPT_DIR=$(dirname $(readlink -f $0))

echo "starting multicast-relay"
echo "Using Interfaces: ${INTERFACES}"
echo "Using Options --foreground " $OPTS
python3 "${SCRIPT_DIR}/multicast-relay.py" --interfaces ${INTERFACES} --foreground $OPTS
EOF

chmod +x /opt/multicast-relay/start.sh

# Install and enable a systemd service
cat <<'EOF' | tee /etc/systemd/system/multicast-relay.service
[Unit]
Description=multicast relay service

[Service]
PassEnvironment=INTERFACES OPTS
ExecStart=/opt/multicast-relay/start.sh

[Install]
WantedBy=multi-user.target
EOF

systemctl enable multicast-relay.service