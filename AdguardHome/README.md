# Run AdguardHome on your UDM

## Features

1. Run AdguardHome on your UDM with a completely isolated network stack. This will not port conflict or be influenced by any changes on by Ubiquiti
2. Persists through reboots and firmware updates.

## Requirements

1. You have setup the on boot script described [here](https://github.com/unifi-utilities/unifios-utilities/tree/main/on-boot-script)
1. AdguardHome persists through firmware updates as it will store the configuration in a folder (you need to create this). It needs 2 folders, a Work and Configuration folder. Please create the 2 folders in "/data/". In my example I created "AdguardHome-Confdir" and "AdguardHome-Workdir"

## Customization

- Feel free to change [20-dns.conflist](../cni-plugins/20-dns.conflist) to change the IP and MAC address of the container.
- Update [10-dns.sh](../dns-common/on_boot.d/10-dns.sh) with your own values
- If you want IPv6 support use [20-dnsipv6.conflist](../cni-plugins/20-dnsipv6.conflist) and update [10-dns.sh](../dns-common/on_boot.d/10-dns.sh) with the IPv6 addresses. Also, please provide IPv6 servers to podman using --dns arguments.

## Steps

Please note if you have firmware v2 or above you have to copy all files into /data instead of /mnt/data. You can see what version you are running by running: ubnt-device-info firmware

1. Check if you have either `/mnt/data/` or `/data/` and use the correct one below.
2. Copy [05-install-cni-plugins.sh](../cni-plugins/05-install-cni-plugins.sh) to /data/on_boot.d
3. On your controller, make a Corporate network with no DHCP server and give it a VLAN. For this example we are using VLAN 5. You should confirm the bridge is created for this VLAN by running `netstat -r` otherwise the script will fail. If it is not there, initiate a provisioning of the UDM (Controller > UDM > Config > Manage Device > Force provision).
4. Copy [10-dns.sh](../dns-common/on_boot.d/10-dns.sh) to `/data/on_boot.d` and update its values to reflect your environment
5. Copy [20-dns.conflist](../cni-plugins/20-dns.conflist) to `/data/podman/cni` after generating a MAC address. This will create your podman macvlan network.
6. Execute /data/on_boot.d/05-install-cni-plugins.sh
7. Execute `/data/on_boot.d/10-dns.sh`
8. Run the AdguardHome docker container, be sure to make the directories for your persistent AdguardHome configuration. They are mounted as volumes in the command below.

   ```shell script
   mkdir /data/AdguardHome-Confdir
   mkdir /data/AdguardHome-Workdir

   podman run -d --network dns --restart always  \
       --name adguardhome \
       -v "/data/AdguardHome-Confdir/:/opt/adguardhome/conf/" \
       -v "/data/AdguardHome-Workdir/:/opt/adguardhome/work/" \
       --dns=127.0.0.1 --dns=1.1.1.1 \
       --hostname adguardhome \
       adguard/adguardhome:latest
   ```

9. Browse to 10.0.5.3:3000 and follow the setup wizard
10. Update your DNS Servers to 10.0.5.3 (or your custom ip) in all your DHCP configs.
11. Access the AdguardHome like you would normally.

## Troubleshooting

If you get the following error:

```
Error adding network: failed to create macvlan: cannot assign requested address
```

When starting the container then the MAC address you generated is not good. You can cheat at this point and look at the address of `br$VLAN.mac` with `ifconfig br$VLAN.mac` and use that value.

To start over you must remove the container and the macvlan device:

```
podman container rm adguardhome
podman network rm dns -f # expect an error here
ip link delete br$VLAN.mac
```

You can now run `10-dns.sh` again and start the container again.
