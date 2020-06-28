#!/bin/sh

if [ -d /mnt/data/on_boot.d ]; then
    for i in /mnt/data/on_boot.d/*.sh; do
        if [ -r $i ]; then
            . $i
        fi
    done
fi
