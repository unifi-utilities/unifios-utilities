#!/bin/sh

#####################################################
# ADD RSA KEYS AS BELOW - CHANGE BEFORE RUNNING     #
#####################################################
# set -- "ssh-rsa first key here all keys quoted" \ #
#        "ssh-rsa each line appended with slash " \ #
# 	 "ssh-rsa last one has no backslash"        #
#####################################################
set -- "ssh-rsa AAAABUNCHOFCHARACTERSANDSTUFF me on MyMachine" \
       "ssh-rsa AAAADIFFERENTKEYWITHCHARSETC! user@myhost"

KEYS_FILE="/root/.ssh/authorized_keys"

counter=0
for key in "$@"
do
	## Places public key in ~/.ssh/authorized_keys if not present
	if ! grep -Fxq "$key" "$KEYS_FILE"; then
		let counter++
		echo "$key" >> "$KEYS_FILE"
	fi
done

echo $counter keys added to $KEYS_FILE

echo Converting SSH private key to dropbear format 
#convert ssh key to dropbear for shell interaction
dropbearconvert openssh dropbear /mnt/data/ssh/id_rsa /root/.ssh/id_dropbear

exit 0;
