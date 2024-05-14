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
## Store crontab files in ${DATA_DIR}/cronjobs/ (you will need to create this folder).
## This script will re-add them on startup.

cp ${DATA_DIR}/cronjobs/* /etc/cron.d/
/etc/init.d/crond restart

exit 0
