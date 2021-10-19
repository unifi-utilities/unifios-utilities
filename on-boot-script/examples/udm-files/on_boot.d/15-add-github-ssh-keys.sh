#!/bin/sh
## Config Variables - please edit these
# Set to true to download public keys from a github user account
USE_GITHUB_KEYS=true
# Enter your username on github to get the public keys for
GITHUB_USER="<YOUR_USERNAME>"
# File location for the output of the git download
GITHUB_KEY_PATH="/mnt/data/podman/ssh"
GITHUB_KEY_FILE="${GITHUB_KEY_PATH}/github.keys"
# Set to true to use a file containing a key per line in the format ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAA...\n
USE_KEY_FILE=true
# IF using an input file, list it here
INPUT_KEY_PATH="/mnt/data/podman/ssh"
INPUT_KEY_FILE="${INPUT_KEY_PATH}/ssh.keys"
# The target key file for the script
OUTPUT_KEY_PATH="/root/.ssh"
OUTPUT_KEY_FILE="${OUTPUT_KEY_PATH}/authorized_keys"

## Functions
# This function downloads the keys from the selected github user
download_from_github(){
	if curl --output /dev/null --silent --head --fail https://github.com/${GITHUB_USER}.keys; then
		curl https://github.com/${GITHUB_USER}.keys -o ${GITHUB_KEY_FILE}
		echo "Downloaded keys from Github"
	else
		echo "Could not download ${GITHUB_USER}'s key file from github"
	fi
}
# Write line to the output line. Add the input line as an arguement.
write_to_output(){
		# Check the file exits
		if ! test -f ${OUTPUT_KEY_FILE}; then
			echo "File at ${OUTPUT_KEY_FILE} does not exist, creating it"
			touch ${OUTPUT_KEY_FILE}
		fi
		echo "${1}" >> ${OUTPUT_KEY_FILE}
}
# This function reads keys from a file into the requested file. The arguement is the input file.
use_key_from_file(){
	if ! test -f $1; then
		echo "File $1 does not exist"
		return
	fi
	counter=0;
  	while IFS= read -r line;
	do
		write_to_output "${line}"
		let "counter++"
	done < $1
	echo "${counter} number of entries read from "
}

## Script
# Makes paths if they don't exit
mkdir -p ${GITHUB_KEY_PATH} ${INPUT_KEY_PATH} ${OUTPUT_KEY_PATH}
#Check flags to see which files to use
if [ ${USE_GITHUB_KEYS} = true ]; then
	download_from_github
	use_key_from_file ${GITHUB_KEY_FILE}
fi
if [ ${USE_KEY_FILE} = true ]; then
	use_key_from_file ${INPUT_KEY_FILE}
fi
