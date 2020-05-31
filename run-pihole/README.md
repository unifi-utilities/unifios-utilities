# Run PiHole on your UDM PRo

### Features
1. Run PiHole on your UDM with a completely isolated network stack.  This will not port conflict or be influenced by any changes on by Ubiquiti

### Requirements
1. You have setup the on boot script described in this repo

### Steps
1. Make a network with no DHCP server and give it a vlan.  The files in this repo assume VLAN5
2. Install the CNI plugins with install-cni-plugins.sh
3. Create podman macvlan network.  Copy udm-files/20-dns.conflist to /mnt/data/podman/cni (or a place of your choosing and update on_boot.sh symlink)
3. Update your on_boot.sh to include the commands in udm-files/on_boot.sh.  You can leave out the iptables stuff if you don't want to DNAT all DNS calls to your PiHole
4. Execute on_boot.sh
5. Run the pihole docker container, be sure to make the directories for your persistent pihole configuration.  They are mounted as volumes in the commmand below.

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
    pihole/pihole:latest
```

6. Set pihole password
```
podman exec -it pihole pihole -a -p YOURNEWPASSHERE
```
6. Update your DNS Servers to 10.0.5.3 in all your DHCP configs.
7. Access the pihole like you would normally.  http://10.0.5.3/
