#!/bin/bash
# Get DataDir location
DATA_DIR="/data"
case "$(ubnt-device-info firmware || true)" in
1*)
    DATA_DIR="/mnt/data"
    ;;
2*)
    DATA_DIR="/data"
    ;;
3*)
    DATA_DIR="/data"
    ;;
*)
    echo "ERROR: No persistent storage found." 1>&2
    exit 1
    ;;
esac
## Configure shell profile

device_info() {
    echo $(/usr/bin/ubnt-device-info "$1")
}

# Modify login banner (motd)
cat >/etc/motd <<EOF
Welcome to UniFi Dream Machine!
(c) 2010-$(date +%Y) Ubiquiti Inc. | http://www.ui.com

Model:       $(device_info model)
Version:     $(device_info firmware)
MAC Address: $(device_info mac)
EOF

# Extend UbiOS prompt to include useful information
cat >/etc/profile.d/prompt.sh <<'EOF'
UDM_NAME="$(grep -m 1 '^name:' ${DATA_DIR}/unifi-core/config/settings.yaml | awk -F: '{ gsub(/^[ \t]+|[ \t]+$/, "", $2); print tolower($2) }')"
PROMPT_MAIN="\u@${UDM_NAME}:\w"

export PS1="[UDM] ${PROMPT_MAIN}${PS1}"
EOF

# Copy all global profile scripts (for all users) from `${DATA_DIR}/on_boot.d/settings/profile/global.profile.d/` directory
mkdir -p ${DATA_DIR}/on_boot.d/settings/profile/global.profile.d
cp -rf ${DATA_DIR}/on_boot.d/settings/profile/global.profile.d/* /etc/profile.d/
