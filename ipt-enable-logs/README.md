# Enable log tags on your UDM

## Features

If you're used to the Unifi Security Gateway, you may miss the USG log prefixes that allow you to know which rule blocked certain traffic.

This mod adds logging prefixes to messages from `/var/log/messages` allowing you to trace a particular log message to the respective iptable rule (which is generated from the firewall rules you configure on the Network application, among other things)

## Requirements

1. You have successfully setup the on boot script described [here](https://github.com/unifi-utilities/unifios-utilities/tree/main/on-boot-script)

## General idea

This mod builds a small Go program that modifies the existing iptables to add `--log-prefix` to entries that are defined as loggable through the `-j LOG` directive. The Go program is built in a Docker container local to the UDM.

Here's an example snippet of an iptable modified by this program:

```
-A UBIOS_WAN_IN_USER -d 192.168.16.10/32 -p udp -m udp --dport 51820 -m conntrack --ctstate NEW -j LOG --log-prefix "[FW-A-WAN_IN_U-3010] "
-A UBIOS_WAN_IN_USER -d 192.168.16.10/32 -p udp -m udp --dport 51820 -m conntrack --ctstate NEW -m comment --comment 00000000008589937602 -j RETURN
-A UBIOS_WAN_IN_USER -d 192.168.16.10/32 -p udp -m udp --dport 51821 -m conntrack --ctstate NEW -j LOG --log-prefix "[FW-A-WAN_IN_U-3011] "
-A UBIOS_WAN_IN_USER -d 192.168.16.10/32 -p udp -m udp --dport 51821 -m conntrack --ctstate NEW -m comment --comment 00000000008589937603 -j RETURN
```

## Steps

1. Copy [on_boot.d/30-ipt-enable-logs-launch.sh](./on_boot.d/30-ipt-enable-logs-launch.sh) to /data/on_boot.d
1. Copy the [scripts/ipt-enable-logs](./scripts/ipt-enable-logs) folder to /data/scripts
1. Copy [scripts/ipt-enable-logs.sh](./scripts/ipt-enable-logs.sh) to /data/scripts
1. Execute /data/on_boot.d/30-ipt-enable-logs-launch.sh
1. Copy [scripts/refresh-iptables.sh](./scripts/refresh-iptables.sh) to /data/scripts

## Refreshing iptables

Whenever you update the firewall rules on the Network application, the iptables will be reprovisioned and will need to be reprocessed
by calling /data/scripts/refresh-iptables.sh.

## Looking at logs

Logs can be followed easily from another machine through SSH by using the following bash functions:

```shell
function logunifijson() {
  ssh unifi "tail -f /var/log/messages" | \
    rg "kernel:" | \
    sed "s/]IN/] IN/" | \
    jq --unbuffered -R '. | rtrimstr(" ") | split(": ") | {date: (.[0] | split(" ") | .[0:3] | join(" "))} + (.[1] | capture("\\[.+\\] \\[(?<rule>.*)\\].*")) + ((.[1] | capture("\\[.+\\] (?<rest>.*)") | .rest | split(" ") | map(select(startswith("[") == false) | split("=") | {(.[0]): .[1]})) | (reduce .[] as $item ({}; . + $item)))'
}

function logunifi() {
  logunifijson | jq --unbuffered -r '"\(.date) - \(.rule)\tIN=\(.IN)  \t\(.PROTO)\tSRC=\(.SRC)@\(.SPT)\tDST=\(.DST)@\(.DPT)\tLEN=\(.LEN)\t"'
}
```

Here's what the output of `logunifi` looks like:

```
Nov 14 10:58:31 - A-LAN_LOCAL_U-2000	IN=br0  	TCP	SRC=192.168.16.10@55804	DST=192.168.16.1@443	LEN=52
Nov 14 10:58:31 - A-LAN_LOCAL_U-2000	IN=br0  	TCP	SRC=192.168.16.10@55804	DST=192.168.16.1@443	LEN=52
Nov 14 10:58:31 - A-LAN_LOCAL_U-2000	IN=br0  	TCP	SRC=192.168.16.10@55804	DST=192.168.16.1@443	LEN=52
Nov 14 10:58:31 - A-LAN_LOCAL_U-2000	IN=br0  	TCP	SRC=192.168.16.10@55804	DST=192.168.16.1@443	LEN=52
Nov 14 10:58:31 - A-LAN_LOCAL_U-2000	IN=br0  	TCP	SRC=192.168.16.10@55804	DST=192.168.16.1@443	LEN=52
Nov 14 10:58:31 - A-LAN_LOCAL_U-2000	IN=br0  	TCP	SRC=192.168.16.10@55804	DST=192.168.16.1@443	LEN=52
```

## Acknowledgements

Thanks a lot to [@opustecnica](https://github.com/opustecnica) for the [initial implementation](https://github.com/opustecnica/public/wiki/UDM-&-UDM-PRO-NOTES) and idea (based on a bash script)!
