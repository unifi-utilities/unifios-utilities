#!/bin/bash

if which unifi-os >/dev/null 2>&1; then
  echo 'Cowardly refusing to install on UDM 1.x'
  exit 1
fi

udm_model() {
  case "$(ubnt-device-info model || true)" in
  "UniFi Dream Machine SE")
    echo "udmse"
    ;;
  "UniFi Dream Machine Pro")
    echo "udmpro"
    ;;
  "UniFi Dream Machine")
    echo "udm"
    ;;
  "UniFi Dream Router")
    echo "udr"
    ;;
  *)
    echo "unknown"
    ;;
  esac
}

DESIRED_ZIPFILE='udmse-podman-install.zip'
case "$(udm_model)" in
udmse | udmpro)
  DESIRED_ZIPFILE="$(udm_model)-podman-install.zip"
  ;;
udm)
  # base UDM works fine with udmpro podman version, but has issues with udmse variant
  DESIRED_ZIPFILE="udmpro-podman-install.zip"
  ;;
*)
  # shrug
  # udmse-podman-install.zip seems to work fine on UDM 2.4.x
  true
  ;;
esac

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

CACHE_DIR="${DATA_DIR}/podman/cache"
INSTALL_ROOT="${DATA_DIR}/podman/install"
CONF_DIR="${DATA_DIR}/podman/conf"

mkdir -p "${CACHE_DIR}" "${INSTALL_ROOT}" "${CONF_DIR}"

URL="https://unifi.boostchicken.io/${DESIRED_ZIPFILE}"

if [ "$1" = '--download-only' ]; then
  echo "downloading ${URL}" &&
    curl -Lsfo "${CACHE_DIR}/${DESIRED_ZIPFILE}" "${URL}" &&
    echo "downloaded ${URL}"
  exit $?
fi

if podman version >/dev/null 2>&1; then
  if [ "$1" = '--force' ]; then
    echo 'overwriting existing podman install (--force)'
  else
    echo 'podman is already installed; skipping'
    exit 0
  fi
fi

if [ -f "${CACHE_DIR}/${DESIRED_ZIPFILE}" ]; then
  echo "(using cache at ${CACHE_DIR}/${DESIRED_ZIPFILE})"
elif echo "downloading ${URL}" &&
  curl -Lsfo "${CACHE_DIR}/${DESIRED_ZIPFILE}" "${URL}"; then
  echo "downloaded ${URL}"
else
  echo 'download failed'
  exit 1
fi

unzip -o "${CACHE_DIR}/${DESIRED_ZIPFILE}" -d "${CACHE_DIR}" >/dev/null
unzip -o "${CACHE_DIR}/podman-install.zip" -d "${INSTALL_ROOT}" >/dev/null
rm -f "${CACHE_DIR}/podman-install.zip"

for SOURCE in $(find "${INSTALL_ROOT}" -not -type d); do
  TARGET="$(expr "${SOURCE}" : "${INSTALL_ROOT}\(.*\)")"
  mkdir -p "$(dirname "${TARGET}")"
  ln -sf "${SOURCE}" "${TARGET}"
done

# fix missing config files
for CONFIG in $(cd "${CONF_DIR}" && echo *); do
  [ -e "${CONF_DIR}/${CONFIG}" ] || continue
  ln -sf "${CONF_DIR}/${CONFIG}" "/etc/containers/${CONFIG}"
done

if podman version >/dev/null 2>&1; then
  echo "podman $(podman version -f '{{.Client.Version}}') was installed successfully"
  exit 0
fi

echo 'Something went wrong'
exit 1
