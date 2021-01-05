#!/bin/sh

MY_SSH_KEY="ADD PUBLIC SSH KEY HERE"
KEYS_FILE="/root/.ssh/authorized_keys"

# Places public key in ~/.ssh/authorized_keys if not present
if ! grep -Fxq "$MY_SSH_KEY" "$KEYS_FILE"; then
    echo "$MY_SSH_KEY" >> "$KEYS_FILE"
fi

