#!/usr/bin/env sh

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
# A change in the name udm-boot would need to be reflected as well in systemctl calls.
SYSTEMCTL_PATH="/etc/systemd/system/udm-boot.service"
SYMLINK_SYSTEMCTL="/etc/systemd/system/multi-user.target.wants/udm-boot.service"

CNI_PLUGINS_SCRIPT_RAW_URL="https://raw.githubusercontent.com/unifi-utilities/unifios-utilities/HEAD/cni-plugins/05-install-cni-plugins.sh"
CNI_PLUGINS_ON_BOOT_FILENAME="$(basename "$CNI_PLUGINS_SCRIPT_RAW_URL")"

CNI_BRIDGE_SCRIPT_RAW_URL="https://raw.githubusercontent.com/unifi-utilities/unifios-utilities/main/on-boot-script-2.x/examples/udm-networking/on_boot.d/06-cni-bridge.sh"
CNI_BRIDGE_ON_BOOT_FILENAME="$(basename "$CNI_BRIDGE_SCRIPT_RAW_URL")"

GITHUB_API_URL="https://api.github.com/repos"
GITHUB_REPOSITORY="unifi-utilities/unifios-utilities"

# --- Functions ---

header() {
  cat <<EOF
  _   _ ___  __  __   ___           _
 | | | |   \|  \/  | | _ ) ___  ___| |_
 | |_| | |) | |\/| | | _ \/ _ \/ _ \  _|
  \___/|___/|_|  |_| |___/\___/\___/\__|

 Execute any script when your udm system
 starts.

EOF
}

command_exists() {
  command -v "${1:-}" >/dev/null 2>&1
}

depends_on() {
  ! command_exists "${1:-}" && echo "Missing dependencie(s): \`$*\`" 1>&2 && exit 1
}

udm_model() {
  case "$(ubnt-device-info model || true)" in
  "UniFi Dream Machine SE")
    echo "udmse"
    ;;
  "UniFi Dream Machine Pro")
    if test $(ubnt-device-info firmware) \< "2.0.0"; then
      echo "udmprolegacy"
    else
      echo "udmpro"
    fi
    ;;
  "UniFi Dream Machine")
    if test $(ubnt-device-info firmware) \< "2.0.0"; then
      echo "udmlegacy"
    else
      echo "udm"
    fi
    ;;
  "UniFi Dream Router")
    echo "udr"
    ;;
  "UniFi Dream Machine Pro Max")
    echo "udmpromax"
    ;;
  "UniFi Cloud Gateway Ultra")
    echo "ucgult"
    ;;
  "UniFi Cloud Gateway Max")
    echo "uxgmax"
    ;;
  "UniFi Express")
    echo "ux"
    ;;
  *)
    echo "unknown"
    ;;
  esac
}

get_latest_download_url() {
  depends_on awk

  curl -fsL "${GITHUB_API_URL}/${GITHUB_REPOSITORY}/releases/latest" |
    awk '$0 ~ /"browser_download_url"/ {sub(/.*:\s*"/,"",$0); gsub("\"", "", $0); print $0}'
}

# download_on_path <path> <url>
download_on_path() {
  [ $# -lt 2 ] &&
    echo "Missing arguments: \`$*\`" 1>&2 &&
    return 1

  curl -sLJo "$1" "$2"

  [ -r "$1" ]
}

install_on_boot_udm_series() {
  download_url="$(get_latest_download_url)"
  tmp_path="/tmp/$(basename "${download_url}")"

  podman exec unifi-os systemctl disable udmboot >/dev/null 2>&1 || true
  podman exec unifi-os systemctl disable udm-boot >/dev/null 2>&1 || true
  podman exec unifi-os systemctl daemon-reload >/dev/null 2>&1 || true
  podman exec unifi-os rm -rf /etc/init.d/udm.sh >/dev/null 2>&1 || true
  podman exec unifi-os rm -f "/etc/systemd/system/udmboot.service" "/etc/systemd/system/udm-boot.service" >/dev/null 2>&1 || true

  echo "Downloading UDM boot package..."
  podman exec unifi-os curl -sLJo "$tmp_path" "$download_url" || return 1
  echo
  sleep 1s

  echo "Installing UDM boot package..."
  podman exec unifi-os dpkg -i "$tmp_path" || return 1
  echo

  unset download_url tmp_path
}

# Credits @peacey: https://github.com/unifi-utilities/unifios-utilities/issues/214#issuecomment-886869295
udmse_on_boot_systemd() {
  cat <<EOF
[Unit]
Description=Run On Startup UDM
Wants=network-online.target
After=network-online.target

[Service]
Type=forking
ExecStart=bash -c 'mkdir -p ${DATA_DIR}/on_boot.d && find -L ${DATA_DIR}/on_boot.d -mindepth 1 -maxdepth 1 -type f -print0 | sort -z | xargs -0 -r -n 1 -- bash -c \'if test -x "\$0"; then echo "%n: running \$0"; "\$0"; else case "\$0" in *.sh) echo "%n: sourcing \$0"; . "\$0";; *) echo "%n: ignoring \$0";; esac; fi\''

[Install]
WantedBy=multi-user.target

EOF
}

install_on_boot_udr_se() {
  systemctl disable udm-boot
  systemctl daemon-reload
  rm -f "$SYMLINK_SYSTEMCTL"

  echo "Creating systemctl service file"
  udmse_on_boot_systemd >"$SYSTEMCTL_PATH" || return 1
  sleep 1s

  echo "Enabling UDM boot..."
  systemctl daemon-reload
  systemctl enable "udm-boot"
  systemctl start "udm-boot"

  [ -e "$SYMLINK_SYSTEMCTL" ]
}

# --- main ---

header

depends_on ubnt-device-info
depends_on curl

ON_BOOT_D_PATH="${DATA_DIR}/on_boot.d"

case "$(udm_model)" in
udmlegacy | udmprolegacy)
  echo "$(ubnt-device-info model) version $(ubnt-device-info firmware) was detected"
  echo "Installing on-boot script..."
  depends_on podman

  if ! install_on_boot_udm_series; then
    echo
    echo "Failed to install on-boot script service" 1>&2
    exit 1
  fi

  echo "UDM Boot Script installed"
  ;;

udr | udmse | udm | udmpro | udmpromax | uxgmax | ucgult | ux)
  echo "$(ubnt-device-info model) version $(ubnt-device-info firmware) was detected"
  echo "Installing on-boot script..."
  depends_on systemctl

  if ! install_on_boot_udr_se; then
    echo
    echo "Failed to install on-boot script service" 1>&2
    exit 1
  fi

  echo "UDM Boot Script installed"
  ;;
*)
  echo "Unsupported model: $(ubnt-device-info model)" 1>&2
  exit 1
  ;;
esac
echo

if [ ! -f "${ON_BOOT_D_PATH}/${CNI_PLUGINS_ON_BOOT_FILENAME}" ]; then
  echo "Downloading CNI plugins script..."
  if
    ! download_on_path "${ON_BOOT_D_PATH}/${CNI_PLUGINS_ON_BOOT_FILENAME}" "$CNI_PLUGINS_SCRIPT_RAW_URL"
  then
    echo
    echo "Failed to download CNI plugins script" 1>&2
    exit 1
  fi
else
  echo "Downloading of CNI bridge script skipped"
fi
chmod +x "${ON_BOOT_D_PATH}/${CNI_PLUGINS_ON_BOOT_FILENAME}"
echo "CNI plugins script installed"
echo "Executing CNI plugins script..."
"${ON_BOOT_D_PATH}/${CNI_PLUGINS_ON_BOOT_FILENAME}" || true
echo

if [ ! -f "${ON_BOOT_D_PATH}/${CNI_BRIDGE_ON_BOOT_FILENAME}" ]; then
  echo "Downloading CNI bridge script..."
  if
    ! download_on_path "${ON_BOOT_D_PATH}/${CNI_BRIDGE_ON_BOOT_FILENAME}" "$CNI_BRIDGE_SCRIPT_RAW_URL"
  then
    echo
    echo "Failed to download CNI bridge script" 1>&2
    exit 1
  fi
else
  echo "Downloading of CNI bridge script skipped"
fi
chmod +x "${ON_BOOT_D_PATH}/${CNI_BRIDGE_ON_BOOT_FILENAME}"
echo "CNI bridge script installed"
echo "Executing CNI bridge script..."
echo "${ON_BOOT_D_PATH}/${CNI_BRIDGE_ON_BOOT_FILENAME}"
"${ON_BOOT_D_PATH}/${CNI_BRIDGE_ON_BOOT_FILENAME}" || true
echo

echo "On boot script installation finished"
echo
echo "You can now place your scripts in \`${ON_BOOT_D_PATH}\`"
echo
