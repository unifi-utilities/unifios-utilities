#!/bin/bash
CONTAINER=cloudflare-ddns
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
# Check if the directory exists
if [ ! -d "$DATA_DIR/cloudflare-ddns" ]; then
  # If it does not exist, create the directory
  mkdir -p "$DATA_DIR/cloudflare-ddns"
  echo "Directory '$DATA_DIR/cloudflare-ddns' created."
else
  # If it already exists, print a message
  echo "Directory '$DATA_DIR/cloudflare-ddns' already exists. Moving on."
fi

# Starts a cloudflare ddns container that is deleted after it is stopped.
# All configs stored in /data/cloudflare-ddns
# Fix for UnifiOS 3.x since podman doesn't work without kernel rebuild (https://github.com/unifi-utilities/unifios-utilities/issues/523) 
if hash podman 2>/dev/null; then
  if podman container exists "$CONTAINER"; then
    podman start "$CONTAINER"
  else
    podman run -i -d --rm \
      --net=host \
      --name "$CONTAINER" \
      --security-opt=no-new-privileges \
      -v $DATA_DIR/cloudflare-ddns/config.json:/config.json \
      timothyjmiller/cloudflare-ddns:latest
  fi
else
  echo "Podman could not be found. Using systemd-service instead..."

  # Check if systemd-service files already exist in /etc/systemd/system
  if [ -f /etc/systemd/system/cloudflare-ddns.timer ]; then
    echo "cloudflare-ddns already exists. Killing service and deleting files..."
    systemctl stop cloudflare-ddns.timer
    systemctl disable cloudflare-ddns.timer
    rm -f /etc/systemd/system/cloudflare-ddns.timer
    rm -f /etc/systemd/system/cloudflare-ddns.service
  fi

  # Copy cloudflare-ddns.timer and cloudflare-ddns.service to /etc/systemd/system
  echo "Installing cloudflare-ddns.timer and cloudflare-ddns.service..."
  cp ../../nspawn-container/cloudflare-ddns.service /etc/systemd/system/cloudflare-ddns.service
  cp ../../nspawn-container/cloudflare-ddns.timer /etc/systemd/system/cloudflare-ddns.timer

  # Get latest files from cloudflare-ddns GitHub Repo (https://github.com/timothymiller/cloudflare-ddns)
  cd $DATA_DIR/cloudflare-ddns
  curl -LJO https://raw.githubusercontent.com/timothymiller/cloudflare-ddns/master/cloudflare-ddns.py
  curl -LJO https://raw.githubusercontent.com/timothymiller/cloudflare-ddns/master/requirements.txt
  curl -LJO https://raw.githubusercontent.com/timothymiller/cloudflare-ddns/master/start-sync.sh

  # Install python3-pip and python3-venv
  apt-get install -y python3-pip python3-venv

  # Make start-sync.sh executable
  chmod +x start-sync.sh
  systemctl start cloudflare-ddns.timer
  systemctl enable cloudflare-ddns.timer
fi