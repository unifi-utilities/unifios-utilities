# Persist changes

Do you want to make some custom changes to your UDM which Unifi hasn't released yet?
Would you like to make some changes that on EdgeOS would be achieved with config.something.yml?

If you just make changes to the interfaces, Unifi will overwrite what you've done periodically/next time you change something.
Luckily we can hook into Unifi's state file and perform the updates immediately afterwards.

For example, [configuring two IP addresses on your WAN interface, so that you can get to your modem's configuration](https://community.ui.com/questions/Access-modem-connected-to-USG/db5986b8-26cb-4d66-a332-2ace81ac8c4f#answer/7da28d8d-25c8-4ca3-b455-c6eba836f034).

## Installation

1. [Enable on-boot-script](https://github.com/unifi-utilities/unifios-utilities/blob/main/on-boot-script/README.md)
1. Copy `42-watch-for-changes.sh` to `/data/on_boot.d/`
   - Check the `FILE` variable, it should point to a file that exists, it might be in `/data` or in `/data`
1. Copy `on-state-change.sh` to `/data/scripts/`
1. Edit `/data/scripts/on-state-change.sh` to your heart's content

> Make sure that your script doesn't error in the likely case that it tries to execute an update which has already been made

## Example: configuring two IP addresses on your WAN interface

`/data/scripts/on-state-change.sh`

```
#!/bin/bash

# give port9 this IP, allows access to router web interface
ip addr add 192.168.0.2/24 dev eth8 || true
```
