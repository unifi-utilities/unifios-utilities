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
## Places public keys in ~/.ssh/authorized_keys

KEYS_SOURCE_FILE="${DATA_DIR}/on_boot.d/settings/ssh/authorized_keys"
KEYS_TARGET_FILE="/root/.ssh/authorized_keys"

count_added=0
count_skipped=0
while read -r key; do
	# Places public key in ~/.ssh/authorized_keys if not present
	if ! grep -Fxq "$key" "$KEYS_TARGET_FILE"; then
		let count_added++
		echo "$key" >>"$KEYS_TARGET_FILE"
	else
		let count_skipped++
	fi
done <"$KEYS_SOURCE_FILE"

echo "${count_added} keys added to ${KEYS_TARGET_FILE}"
if [ $count_skipped -gt 0 ]; then
	echo "${count_skipped} already added keys skipped"
fi

# Convert ssh key to dropbear for shell interaction
echo "Converting SSH private key to dropbear format"
dropbearconvert openssh dropbear ${DATA_DIR}/ssh/id_rsa /root/.ssh/id_dropbear

exit 0
