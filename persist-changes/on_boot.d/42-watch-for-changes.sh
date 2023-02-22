#!/bin/sh

EXECUTE01='/data/scripts/on-state-change.sh'
FILE="/data/udapi-config/ubios-udapi-server/ubios-udapi-server.state"
# /usr/bin/logger -t "${PROCESSNAME}" "$*"

# run on boot aswell
$EXECUTE01

if [ "$1" = "DAEMON" ]; then
    # is this necessary? Add other signals at will (TTIN TTOU INT STOP TSTP)
    trap '' INT
    cd /tmp
    shift
    ### daemonized section ######
    # RUNNING=`ps aux | grep $CMD | grep -v grep | wc -l`
    # echo $RUNNING
    # if [ "$RUNNING" -lt 1 ]; then
    LAST=`ls -l "$FILE"`
    # echo $LAST
    while true; do
      sleep 1
      NEW=`ls -l "$FILE"`
      # echo $NEW
      if [ "$NEW" != "$LAST" ]; then
        DATE=`date`
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