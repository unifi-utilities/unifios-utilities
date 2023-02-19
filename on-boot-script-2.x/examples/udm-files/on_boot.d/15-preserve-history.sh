#!/bin/sh

mkdir -p /mnt/data/.home

for file in .ash_history .bash_history
if [ ! -f /mnt/data/.home/$file ]; then
  touch /root/$file
  cp /root/$file /mnt/data/.home/$file
  chown root:root /mnt/data/.home/$file
  chmod 0600 /mnt/data/.home/$file
fi
ln -sf /mnt/data/.home/$file /root/$file

