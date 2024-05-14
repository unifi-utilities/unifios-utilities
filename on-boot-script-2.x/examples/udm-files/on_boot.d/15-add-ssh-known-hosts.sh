#!/bin/bash
# Get DataDir location
DATA_DIR="/data"case "$(ubnt-device-info firmware || true)" in
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
#####################################################
# ADD KNOWN HOSTS AS BELOW - CHANGE BEFORE RUNNING  #
#####################################################
# set -- "known host text on a line with quotes " \ #
#        "second known host on another line "     \ #
# 	 "one per line, last line has no backslash" #
#####################################################
set -- "hostname ecdsa-sha2-nistp256 AAAABIGHOSTIDENTIFIERWITHMAGICSTUFF=" \
	"otherhost ecdsa-sha2-nistp256 AAAADIFFERENTHOSTMAGICSTUFF!@HJKSL="

KNOWN_HOSTS_FILE="/root/.ssh/known_hosts"

counter=0
for host in "$@"; do
	## Places known host in ~/.ssh/known_hosts if not present
	if ! grep -Fxq "$host" "$KNOWN_HOSTS_FILE"; then
		let counter++
		echo "$host" >>"$KNOWN_HOSTS_FILE"
	fi
done

echo $counter hosts added to $KNOWN_HOSTS_FILE

exit 0
