# Run PiHole on your UDM

### Features
1. Run PiHole on your UDM with a completely isolated network stack.  This will not port conflict or be influenced by any changes on by Ubiquiti
2. Persists through reboots and firmware updates.

### Requirements
1. You have setup the on boot script described [here](https://github.com/boostchicken/udmpro-utilities/tree/master/on-boot-script)
2. PiHole persists through firmware updates. The on-boot script does not.  If you update your firmware, setup on-boot again and everything should work.

### Customization
* Feel free to change [20-dns.conflist](https://github.com/boostchicken/udm-utilities/blob/master/run-pihole/udm-files/20-dns.conflist) to change the IP address of the container. Make sure to update all ip references and the iptables rules in [on_boot.sh](https://github.com/boostchicken/udm-utilities/blob/master/run-pihole/udm-files/on_boot.sh).  The IP address can be anywhere from x.x.x.3 to x.x.x.254. .1 is reserved for the gateway and .2 is reserved for the macvlan bridge.
* If you don't want to use vlan5, just replace br5 with br(vlanid) in [on_boot.sh](https://github.com/boostchicken/udm-utilities/blob/master/run-pihole/udm-files/on_boot.sh) and [20-dns.conflist](https://github.com/boostchicken/udm-utilities/blob/master/run-pihole/udm-files/20-dns.conflist), also update all the ips accordingly

### Steps
1. On your controller, make a Corporate network with no DHCP server and give it a VLAN. For this example we are using VLAN 5.
2. Install the CNI plugins with by executing [install-cni-plugins.sh](https://github.com/boostchicken/udm-utilities/blob/master/run-pihole/install-cni-plugins.sh) on your UDM
3. Copy [20-dns.conflist](https://github.com/boostchicken/udm-utilities/blob/master/run-pihole/udm-files/20-dns.conflist) to /mnt/data/podman/cni (or a place of your choosing and update [on_boot.sh](https://github.com/boostchicken/udm-utilities/blob/master/run-pihole/udm-files/on_boot.sh) symlink).  This will create your podman macvlan network
4. Update your on_boot.sh to include the commands in [on_boot.sh](https://github.com/boostchicken/udm-utilities/blob/master/run-pihole/udm-files/on_boot.sh).  You can leave out the iptables rules if you don't want to DNAT all DNS calls to your PiHole
5. Execute on_boot.sh
6. Run the pihole docker container, be sure to make the directories for your persistent pihole configuration.  They are mounted as volumes in the command below.

```
 podman run -d --network dns \
    --name pihole \
    -e TZ="America/Los Angeles" \
    -v "/mnt/data/etc-pihole/:/etc/pihole/" \
    -v "/mnt/data/pihole/etc-dnsmasq.d/:/etc/dnsmasq.d/" \
    --dns=127.0.0.1 --dns=1.1.1.1 \
    --hostname pi.hole \
    -e VIRTUAL_HOST="pi.hole" \
    -e PROXY_LOCATION="pi.hole" \
    -e ServerIP="10.0.5.3" \
    -e IPv6="False" \
    pihole/pihole:latest
```

The below errors are expected and acceptable
```
ERRO[0022] unable to get systemd connection to add healthchecks: dial unix /run/systemd/private: connect: no such file or directory
ERRO[0022] unable to get systemd connection to start healthchecks: dial unix /run/systemd/private: connect: no such file or directory
```
7. Set pihole password
```
podman exec -it pihole pihole -a -p YOURNEWPASSHERE
```
8. Update your DNS Servers to 10.0.5.3 (or your custom ip) in all your DHCP configs.
9. Access the pihole like you would normally.
