# Container common settings

## Features

1. **Stable disk usage footprint**: Sets a maximum log size any podman container log is allowed to grow up to (from unlimited size to 100Mb). Log "max size" is not a hard limit, but a point when Container Monitor attempts to truncate container log file. **NOTE:** application-specific logs that may be written outside container logs are not truncated by Container Monitor at set limits.

## Requirements

1. You have already setup the on boot script described [here](https://github.com/boostchicken/udm-utilities/tree/master/on-boot-script)

## Customization

While a 100Mb log limit per container should give plenty of log data for all featured in this repo projects, you can increase or decrease max_log_size value in /mnt/data/on_boot.d/05-container-common.sh file after installation.

## Steps

1. Run as root on UDM Pro to download and set permissions of on_boot.d script:
```sh
# Download 05-container-common.sh from GitHub
curl -L https://raw.githubusercontent.com/boostchicken/udm-utilities/master/container-common/on_boot.d/05-container-common.sh -o /mnt/data/on_boot.d/05-container-common.sh;
# Set execute permission
chmod a+x /mnt/data/on_boot.d/05-container-common.sh;
```
2. Review the script /mnt/data/on_boot.d/05-container-common.sh and when happy execute it.
```sh
# Review script
cat /mnt/data/on_boot.d/05-container-common.sh;
# Apply container-common settings
/mnt/data/on_boot.d/05-container-common.sh;
```
3. Already running containers will pick up new defaults after either container restart ("podman restart \<container-name\>") or after UDM Pro restart. New containers will pick up a change from first run.
4. To list containers that are running with log size limits:
```sh
# List container monitor processes with "--log-size-max" custom argument set
ps -ef | grep conmon | grep log-size-max
```
