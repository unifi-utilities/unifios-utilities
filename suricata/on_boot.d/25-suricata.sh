#!/bin/sh

APP_PID="/run/suricata.pid"

echo "#!/bin/sh
CUSTOM_RULES=\"/mnt/data/suricata-rules\"

for file in \"\$CUSTOM_RULES\"/*.rules
do
    if [ -f \"\$file\" ]; then
        cp \"\$file\" \"/run/ips/rules/\$(basename \"\$file\")\"
        echo \" - \$(basename \"\$file\")\" >> /run/ips/config/rules.yaml
    fi
done
CONTAINER=suricata
if podman container exists \${CONTAINER}; then
  podman rm -f \${CONTAINER}
fi
podman run --network=host --privileged --name \${CONTAINER} --rm -it -v /run:/var/run/ -v /run:/run  -v /usr/share/ubios-udapi-server/ips/:/usr/share/ubios-udapi-server/ips/ jasonish/suricata:5.0.3-arm64v8 /usr/bin/suricata \"\$@\"" > /tmp/suricata.sh

chmod +x /tmp/suricata.sh
cp /usr/bin/suricata /tmp/suricata.backup # In case you want to move back without rebooting
ln -f -s /tmp/suricata.sh /usr/bin/suricata

if [ ! -z "$APP_PID" ]; then
  killall -9 suricata
  rm -f APP_PID
fi