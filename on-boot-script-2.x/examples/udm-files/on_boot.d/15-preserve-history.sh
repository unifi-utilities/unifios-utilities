#!/bin/sh

mkdir -p /data/.home

for file in .ash_history .bash_history
if [ ! -f /data/.home/$file ]; then
  touch /root/$file
  cp /root/$file /data/.home/$file
  chown root:root /data/.home/$file
  chmod 0600 /data/.home/$file
fi
ln -sf /data/.home/$file /root/$file

