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
mkdir -p ${DATA_DIR}/.home

for file in .ash_history .bash_history; do
  if [ ! -f ${DATA_DIR}/.home/$file ]; then
    touch /root/$file
    cp /root/$file ${DATA_DIR}/.home/$file
    chown root:root ${DATA_DIR}/.home/$file
    chmod 0600 ${DATA_DIR}/.home/$file
  fi
  ln -sf ${DATA_DIR}/.home/$file /root/$file
done
