#!/usr/bin/env sh

# UniFi Data Directory
DATA_DIR="/data"

# A change in the name udm-boot would need to be reflected as well in systemctl calls.
SYSTEMCTL_PATH="/etc/systemd/system/udm-boot.service"
SYMLINK_SYSTEMCTL="/etc/systemd/system/multi-user.target.wants/udm-boot.service"
SERVICE_META_URL="https://raw.githubusercontent.com/unifi-utilities/unifi-common/HEAD/udm-boot.service"

# --- Functions ---

header() {
  cat <<EOF
  ___         ___            _
 / _ \  _ _  | _ ) ___  ___ | |_
| (_) || ' \ | _ \/ _ \/ _ \|  _|
 \___/ |_||_||___/\___/\___/ \__|

 Execute any script when your system
 starts.

EOF
}

command_exists() {
  command -v "${1:-}" >/dev/null 2>&1
}

depends_on() {
  ! command_exists "${1:-}" && echo "Missing dependency: \`$*\`" 1>&2 && exit 1
}

udm_model() {
  case "$(ubnt-device-info model || true)" in
  "Enterprise Fortress Gateway")
    echo "udment"
    ;;
  "UniFi Cloud Gateway Fiber")
    echo "ucgfiber"
    ;;
  "UniFi Cloud Gateway Max")
    echo "uxgmax"
    ;;
  "UniFi Cloud Gateway Ultra")
    echo "ucgult"
    ;;
  "UniFi Dream Machine")
    echo "udm"
    ;;
  "UniFi Dream Machine Beast")
    echo "udmbeast"
    ;;
  "UniFi Dream Machine Pro")
    echo "udmpro"
    ;;
  "UniFi Dream Machine Pro Max")
    echo "udmpromax"
    ;;
  "UniFi Dream Machine SE")
    echo "udmse"
    ;;
  "UniFi Dream Router")
    echo "udr"
    ;;
  "UniFi Dream Router 7")
    echo "udr7"
    ;;
  "UniFi Dream Wall")
    echo "udw"
    ;;
  "UniFi Express")
    echo "ux"
    ;;
  "UniFi Express 7")
    echo "ux7"
    ;;
  "UniFi NeXt-Gen Gateway Fiber")
    echo "uxgfiber"
    ;;
  *)
    echo "unknown"
    ;;
  esac
}

# download_on_path <path> <url>
download_on_path() {
  [ $# -lt 2 ] &&
    echo "Missing arguments: \`$*\`" 1>&2 &&
    return 1

  curl -sLJo "$1" "$2"

  [ -r "$1" ]
}

install_on_boot_udr_se() {
  systemctl disable udm-boot 2>/dev/null || true
  systemctl daemon-reload
  rm -f "$SYMLINK_SYSTEMCTL"

  echo "Creating systemctl service file"

  if ! download_on_path  "$SYSTEMCTL_PATH" "$SERVICE_META_URL"; then
    echo
    echo "Failed to download on-boot script service" 1>&2
    exit 1
  fi
  sleep 1s

  echo "Enabling UDM boot..."
  systemctl daemon-reload
  systemctl enable "udm-boot"
  systemctl start "udm-boot"

  [ -e "$SYMLINK_SYSTEMCTL" ]
}
header

depends_on ubnt-device-info
depends_on curl

ON_BOOT_D_PATH="${DATA_DIR}/on_boot.d"

case "$(udm_model)" in
udment | ucgfiber | uxgmax | ucgult | udm | udmbeast | udmpro | udmpromax | udmse | udr | udr7 | udw | ux | ux7 | uxgfiber)
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

echo "On boot script installation finished"
echo
echo "You can now place your scripts in \`${ON_BOOT_D_PATH}\`"
echo