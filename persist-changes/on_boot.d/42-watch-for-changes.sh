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

# Check if the directory exists
if [ ! -d "${DATA_DIR}/scripts" ]; then
  # If it does not exist, create the directory
  mkdir -p "${DATA_DIR}/scripts"
  echo "Directory '${DATA_DIR}/scripts' created."
else
  # If it already exists, print a message
  echo "Directory '${DATA_DIR}/scripts' already exists. Moving on."
fi

EXECUTE01="${DATA_DIR}/scripts/on-state-change.sh"
FILE="${DATA_DIR}/udapi-config/ubios-udapi-server/ubios-udapi-server.state"
# /usr/bin/logger -t "${PROCESSNAME}" "$*"

# run on boot aswell
$EXECUTE01

if [ "$1" = "DAEMON" ]; then
  # is this necessary? Add other signals at will (TTIN TTOU INT STOP TSTP)
  trap '' INT
  cd /tmp || exit
  shift
  ### daemonized section ######
  # RUNNING=`ps aux | grep $CMD | grep -v grep | wc -l`
  # echo $RUNNING
  # if [ "$RUNNING" -lt 1 ]; then
  LAST=$(ls -l "$FILE")
  # echo $LAST
  while true; do
    sleep 1
    NEW=$(ls -l "$FILE")
    # echo $NEW
    if [ "$NEW" != "$LAST" ]; then
      DATE=$(date)
      echo "${DATE}: Executing ${EXECUTE01}"
      $EXECUTE01
      LAST="$NEW"
    fi
  done
  # fi
  #### end of daemonized section ####
  exit 0
fi

export PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/sbin:/usr/local/bin
umask 022
# You can add nice and ionice before nohup but they might not be installed
# nohup setsid $0 DAEMON $* 2>/var/log/mydaemon.err >/var/log/mydaemon.log &
nohup setsid $0 DAEMON WATCH $* 2>/var/log/watch.err >/var/log/watch.log &
