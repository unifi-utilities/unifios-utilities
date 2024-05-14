# Rclone

## Features

- Rclone w/ WebGUI

## Requirements

1. You have successfully setup the on boot script described [here](https://github.com/unifi-utilities/unifios-utilities/tree/main/on-boot-script)

## Steps

1. Make a directory for your configuration

   ```sh
   mkdir -p /data/rclone
   ```

2. Create [rclone.conf](https://rclone.org/commands/rclone_config/) in `/data/rclone` and update it to meet yours needs.
3. Copy [sync.sh](sync.sh) in `/data/rclone` and update it to meet your needs.
4. Copy [10-rclone.sh](10-rclone.sh) to `/data/on_boot.d` and update it to meet your needs.
5. Execute `/data/on_boot.d/10-rclone.sh`
6. Execute `podman logs rclone`, this will provide a link to the Web GUI.
7. Copy [rclone](rclone) in `/etc/cron.hourly/`.
8. Set permissions to executable `chmod +x /etc/cron.hourly/rclone`.

## Customization

1. Login to run rclone commands locally to create and test configs

   ```sh
   podman exec -ti rclone /
   ```
