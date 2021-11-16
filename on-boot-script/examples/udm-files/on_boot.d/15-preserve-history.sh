#!/bin/sh

mkdir -p /mnt/data/.home
if [ ! -f /mnt/data/.home/.ash_history ]; then
  cp /root/.ash_history /mnt/data/.home/.ash_history
fi
ln -sf /mnt/data/.home/.ash_history /root/.ash_history
