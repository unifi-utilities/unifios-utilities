# Run AdguardHome on your UDM

### Features
1. Run AdguardHome on your UDM with a completely isolated network stack.  This will not port conflict or be influenced by any changes on by Ubiquiti
2. Persists through reboots and firmware updates.

### Requirements
1. You have setup the on boot script described [here](https://github.com/boostchicken/udmpro-utilities/tree/master/on-boot-script)
2. AdguardHome persists through firmware updates as it will store the configuration in a folder (you need to create this)
It needs 2 folders, a Work and Configuration folder. Plese create the 2 folder in "/mnt/data/". In my example I created "AdguardHome-Confdir" and "AdguardHome-Workdir"
The on-boot script needs to be setup after firmware update of UDM. When on-boot script is recreated, everything should work.

### Customization
* Feel free to change [20-dns.conflist](https://github.com/boostchicken/udm-utilities/blob/master/AdguardHome/udm-files/20-dns.conflist) to change the IP address of the container. Make sure to update all ip references and the iptables rules in [on_boot.sh](https://github.com/boostchicken/udm-utilities/blob/master/AdguardHome/udm-files/on_boot.sh).  The IP address can be anywhere from x.x.x.3 to x.x.x.254. .1 is reserved for the gateway and .2 is reserved for the macvlan bridge.
* If you don't want to use vlan5, just replace br5 with br(vlanid) in [on_boot.sh](https://github.com/boostchicken/udm-utilities/blob/master/AdguardHome/udm-files/on_boot.sh) and [20-dns.conflist](https://github.com/boostchicken/udm-utilities/blob/master/AdguardHome/udm-files/20-dns.conflist), also update all the ips accordingly

### Steps
1. On your controller, make a Corporate network with no DHCP server and give it a VLAN. For this example we are using VLAN 5.
2. Install the CNI plugins with by executing [install-cni-plugins.sh](https://github.com/boostchicken/udm-utilities/blob/master/AdguardHome/install-cni-plugins.sh) on your UDM
3. Copy [20-dns.conflist](https://github.com/boostchicken/udm-utilities/blob/master/AdguardHome/udm-files/20-dns.conflist) to /mnt/data/podman/cni (or a place of your choosing and update [on_boot.sh](https://github.com/boostchicken/udm-utilities/blob/master/AdguardHome/udm-files/on_boot.sh) symlink).  This will create your podman macvlan network
4. Update your on_boot.sh to include the commands in [on_boot.sh](https://github.com/boostchicken/udm-utilities/blob/master/AdguardHome/udm-files/on_boot.sh).  You can leave out the iptables rules if you don't want to DNAT all DNS calls to your PiHole
5. Execute on_boot.sh
6. Run the AdguardHome docker container, be sure to make the directories for your persistent AdguardHome configuration.  They are mounted as volumes in the command below.

```
podman run -d --network dns \
    --name adguardhome \
    -v "/mnt/data/AdguardHome-Confdir/:/opt/adguardhome/conf/" \
    -v "/mnt/data/AdguardHome-Workdir/:/opt/adguardhome/work/" \
    --dns=127.0.0.1 --dns=1.1.1.1 \
    --hostname adguardhome \
    adguard/adguardhome:arm64-latest
```

7. Change on_boot.sh line 17
From
```
#podman start AdguardHome
```
To
```
podman start AdguardHome
```
This makes sure that the AdguardHome container will start after reboot of UDM. 
8. Browse to 10.0.5.3:3000 and follow the setup wizard
9. Update your DNS Servers to 10.0.5.3 (or your custom ip) in all your DHCP configs.
10. Access the AdguardHome like you would normally.
