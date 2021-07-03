#!/bin/sh

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
for host in "$@"
do
	## Places known host in ~/.ssh/known_hosts if not present
	if ! grep -Fxq "$host" "$KNOWN_HOSTS_FILE"; then
		let counter++
		echo "$host" >> "$KNOWN_HOSTS_FILE"
	fi
done

echo $counter hosts added to $KNOWN_HOSTS_FILE


exit 0;
