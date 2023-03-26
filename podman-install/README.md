# Podman Install

## Features

* Automatically install podman from https://unifi.boostchicken.io
* Persists through firmware updates

## Requirements

1. You have successfully set up the on boot script described
   [here](https://github.com/unifi-utilities/unifios-utilities/tree/main/on-boot-script)
2. [Optional] [`25-add-cron-jobs.sh`](https://github.com/unifi-utilities/unifios-utilities/blob/main/on-boot-script/examples/udm-files/on_boot.d/25-add-cron-jobs.sh)

## Installation

1. Copy `on_boot.d/00-podman.sh` to `/data/on_boot.d`
2. Copy the contents of `conf` to `/data/podman/conf`

## Customization

Optional: automatic updates

* Copy `cronjobs/update-podman` to `/data/cronjobs`
* Re-run `/data/on_boot.d/25-add-cron-jobs.sh`

The script can be run manually. Normally, it will refuse to overwrite an existing podman install. If you've installed podman manually, or if you are using UDM 1.x firmware (which includes podman), then the script will do nothing.

If you run `/data/on_boot.d/00-podman.sh --force`, then podman will be reinstalled, even if it aready exists.

Normally, the script will reuse previously-downloaded zip files. This should cause the previously-installed version to be reinstalled automatically after a firmware upgrade.

If you run `/data/on_boot.d/00-podman.sh --download-only`, then the latest zip file will be downloaded from [https://unifi.boostchicken.io/](https://unifi.boostchicken.io/), but not installed.

You can combine the two args to forcefully upgrade to the latest version:

```bash
/data/on_boot.d/00-podman.sh --download-only && /data/on_boot.d/00-podman.sh --force
```

### Why not `podman-update`?

https://github.com/unifi-utilities/unifios-utilities/issues/288#issuecomment-992404375

