#!/bin/sh

echo "#!/bin/sh
ssh -o StrictHostKeyChecking=no root@127.0.1.1 '/mnt/data/on_boot.sh'" > /etc/init.d/udm.sh
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
