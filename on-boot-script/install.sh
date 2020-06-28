#!/bin/sh

echo "Creating on boot script on device"
echo '#!/bin/sh

if [ -d /mnt/data/on_boot.d ]; then
    for i in /mnt/data/on_boot.d/*.sh; do
        if [ -r $i ]; then
            . $i
        fi
    done
fi
' > /mnt/data/on_boot.sh

chmod u+x /mnt/data/on_boot.sh
mkdir -p /mnt/data/on_boot.d

echo "Creating script to modify unifios container"
echo '#!/bin/sh

echo "#!/bin/sh
ssh -o StrictHostKeyChecking=no root@127.0.1.1 ''/mnt/data/on_boot.sh''" > /etc/init.d/udm.sh
chmod u+x /etc/init.d/udm.sh

echo "[Unit]
Description=Run On Startup UDM
After=network.target

[Service]
ExecStart=/etc/init.d/udm.sh

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/udmboot.service

systemctl enable udmboot
systemctl start udmboot
' > /tmp/install-unifios.sh

podman cp /tmp/install-unifios.sh unifi-os:/root/install-unifios.sh
podman exec -it unifi-os chmod +x /root/install-unifios.sh
echo "Executing container modifications"
podman exec -it unifi-os sh -c /root/install-unifios.sh
rm /tmp/install-unifios.sh

echo "Installed on_boot hook. Populate /mnt/data/on_boot.d with scripts to run"