# Run AdguardHome on your UDM

### Features
1. Run AdguardHome on your UDM with a completely isolated network stack.  This will not port conflict or be influenced by any changes on by Ubiquiti
2. Persists through reboots and firmware updates.

### Requirements
1. You have setup the on boot script described [here](https://github.com/boostchicken/udm-utilities/tree/master/on-boot-script)
2. AdguardHome persists through firmware updates as it will store the configuration in a folder (you need to create this). It needs 2 folders, a Work and Configuration folder. Please create the 2 folders in "/mnt/data/". In my example I created "AdguardHome-Confdir" and "AdguardHome-Workdir"
3. The on-boot script needs to be setup after firmware update of UDM. When on-boot script is recreated, everything should work.

### Customization
* Feel free to change [20-dns.conflist](../cni-plugins/20-dns.conflist) to change the IP address of the container.
* Update [10-dns.sh](../dns-common/on_boot.d/10-dns.sh) with your own values
* If you want IPv6 support use [20-dnsipv6.conflist](../cni-plugins/20-dnsipv6.conflist) and [10-dnsipv6.sh](../dns-common/on_boot.d/10-dnsipv6.sh). Also, please provide IPv6 servers to podman using --dns arguments.

### Steps
1. On your controller, make a Corporate network with no DHCP server and give it a VLAN. For this example we are using VLAN 5.
2. Install the CNI plugins with by executing [install-cni-plugins.sh](../cni-plugins/install-cni-plugins.sh) on your UDM
3. Copy [20-dns.conflist](../cni-plugins/20-dns.conflist) to /mnt/data/podman/cni.  This will create your podman macvlan network
4. Copy [10-dns.sh](../dns-common/on_boot.d/10-dns.sh) to /mnt/data/on_boot.d and update its values to reflect your environment
5. Execute /mnt/data/on_boot.d/10-dns.sh
6. Run the AdguardHome docker container, be sure to make the directories for your persistent AdguardHome configuration.  They are mounted as volumes in the command below.

    ```shell script
    podman run -d --network dns --restart always  \
        --name adguardhome \
        -v "/mnt/data/AdguardHome-Confdir/:/opt/adguardhome/conf/" \
        -v "/mnt/data/AdguardHome-Workdir/:/opt/adguardhome/work/" \
        --dns=127.0.0.1 --dns=1.1.1.1 \
        --hostname adguardhome \
        adguard/adguardhome:arm64-latest
    ```

7. Browse to 10.0.5.3:3000 and follow the setup wizard
8. Update your DNS Servers to 10.0.5.3 (or your custom ip) in all your DHCP configs.
9. Access the AdguardHome like you would normally.
