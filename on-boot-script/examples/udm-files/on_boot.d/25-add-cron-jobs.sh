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
## Store crontab files in ${DATA_DIR}/cronjobs/ (you will need to create this folder).
## This script will re-add them on startup.

cp ${DATA_DIR}/cronjobs/* /etc/cron.d/
# Older UDM's had crond, so lets check if its here if so use that one, otherwise use cron
if [ -x /etc/init.d/crond ]; then
  /etc/init.d/crond restart
elif [ -x /etc/init.d/cron ]; then
  /etc/init.d/cron restart
else
  echo "Neither crond nor cron found."
fi

exit 0
