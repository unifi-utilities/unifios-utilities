#!/bin/bssh

## Configure shell profile
PROFILE_SOURCE=/data/settings/profile/global.profile.d
PROFILE_TARGET=/etc/profile.d

device_info() {
  /usr/bin/ubnt-device-info "$1"
}

# Modify login banner (motd)
cat > /etc/motd <<EOF
Welcome to $(device_info model)!
(c) 2010-$(date +%Y) Ubiquiti Inc. | http://www.ui.com

Model:       $(device_info model)
Version:     $(device_info firmware)
MAC Address: $(device_info mac)
EOF

# Extend UbiOS prompt to include useful information
cat > /etc/profile.d/prompt.sh <<'EOF'
UDM_NAME="$(grep -m 1 '^name:' /data/unifi-core/config/settings.yaml | awk -F: '{ gsub(/^[ \t]+|[ \t]+$/, "", $2); print tolower($2) }')"
PROMPT_MAIN="\u@${UDM_NAME}:\w"

export PS1="[UDM] ${PROMPT_MAIN}${PS1}"
EOF

# Copy all global profile scripts (for all users) from `/data/settings/profile/global.profile.d/` directory
mkdir -p ${PROFILE_SOURCE}
cp -rf ${PROFILE_SOURCE}/* ${PROFILE_TARGET}
