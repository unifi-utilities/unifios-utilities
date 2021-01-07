# Chrony-udm (NTP Server)

## On the UDM shell (not unifi-os)

```bash
# enter udm-boot container
podman exec -it udm-boot /bin/bash
# create the container
podman create --detach --restart always --network host --cap-add SYS_TIME --name ntpd tusc/chrony-udm
# generate service file
podman generate systemd ntpd >/etc/systemd/system/ntpd.service
# reload and enable service
systemctl daemon-reload
systemctl enable ntpd.service
systemctl start ntpd.service
```
