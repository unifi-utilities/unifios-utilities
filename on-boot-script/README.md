# UDM / UDMPro Boot Script
### Features
1. Allows you to run a shell script at S95 anytime your UDM starts / reboots

### Compatiblity
1. Should work on any UDM/UDMPro after 1.6.3
2. Tested and confirmed on 1.6.6, 1.7.0, 1.7.2rc4


## Steps
# 1. Make your script on the UDM/UDMPRO
```
vi /mnt/data/on_boot.sh 
chmod u+x /mnt/data/on_boot.sh
```
Example: see examples/udm-files/on_boot.sh
```
#!/bin/sh
podman start wpa_supplicant-udmpro

iptables -t nat -C PREROUTING -p udp ! --source 10.0.0.x ! --destination 10.0.0.x --dport 53 -j DNAT --to 10.0.0.x || iptables -t nat -A PREROUTING -p udp ! --source 10.0.0.x ! --destination 10.0.0.x --dport 53 -j DNAT --to 10.0.0.x
iptables -t nat -C PREROUTING -p tcp ! --source 10.0.0.x ! --destination 10.0.0.x --dport 53 -j DNAT --to 10.0.0.x || iptables -t nat -A PREROUTING -p tcp ! --source 10.0.0.x ! --destination 10.0.0.x --dport 53 -j DNAT --to 10.0.0.x
iptables -t nat -C POSTROUTING -j MASQUERADE || iptables -t nat -A POSTROUTING -j MASQUERADE
```


# 2. Make the unifios docker container execute this script on startup, this has to be done after every firmware update.  It does persist through reboots.

## Automatic
1. Copy install.sh and install-unifios.sh to your UDM
2. Execute install.sh

## Manual
```
podman exec -it unifi-os sh
```
### make a script that sshs to the udm and runs on our boot script
Example: examples/unifi-os-files/udm.sh
```
echo "#!/bin/sh
ssh -o StrictHostKeyChecking=no root@127.0.1.1 '/mnt/data/on_boot.sh'" > /etc/init.d/udm.sh # 127.0.1.1 always points to the UDM
```
#### make said script executable
```
chmod u+x /etc/init.d/udm.sh
```
### make a service that runs on startup, after we have networking
Example: examples/unifi-os-files/udmboot.service
```
echo "[Unit]
Description=Run On Startup UDM

[Service]
After=network.target
ExecStart=/etc/init.d/udm.sh

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/udmboot.service
```

### enable it and test
```
systemctl enable udmboot
systemctl start udmboot
```
### back to the udm
```
exit
```
# reboot your udm/udmpro and make sure it worked
```
reboot
exit
```
