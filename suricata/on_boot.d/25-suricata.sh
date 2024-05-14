#!/bin/bash
# Get DataDir location
DATA_DIR="/data"
case "$(ubnt-device-info firmware || true)" in
1*)
    DATA_DIR="/mnt/data"
    ;;
2* | 3* | 4*)
    DATA_DIR="/data"
    ;;
*)
    echo "ERROR: No persistent storage found." 1>&2
    exit 1
    ;;
esac
# Check if the directory exists
if [ ! -d "${DATA_DIR}/suricata-rules" ]; then
  # If it does not exist, create the directory
  mkdir -p "${DATA_DIR}/suricata-rules"
  echo "Directory '${DATA_DIR}/suricata-rules' created."
else
  # If it already exists, print a message
  echo "Directory '${DATA_DIR}/suricata-rules' already exists. Moving on."
fi
APP_PID="/run/suricata.pid"

cat <<"EOF" >/tmp/suricata.sh
#!/bin/bash
CUSTOM_RULES="${DATA_DIR}/suricata-rules"

for file in $(find ${CUSTOM_RULES} -name '*.rules' -print)
do
    if [ -f "${file}" ]; then
        bname=$(basename ${file})
        cp "${file}" "/run/ips/rules/${bname}"
        # Check if the existing filename is already in the rules.yaml based upon a previous update
        grep -wq "${bname}" /run/ips/config/rules.yaml 
        # Don't add twice if it is in the file already
        if [ $? -ne 0 ]; then 
            echo " - ${bname}" >> /run/ips/config/rules.yaml
        fi
    fi
done
CONTAINER=suricata
if podman container exists ${CONTAINER}; then
  podman rm -f ${CONTAINER}
fi
podman run --network=host --privileged --name ${CONTAINER} --rm -it -v /run:/var/run/ -v /run:/run  -v /usr/share/ubios-udapi-server/ips/:/usr/share/ubios-udapi-server/ips/ jasonish/suricata:5.0.3-arm64v8 /usr/bin/suricata "$@" 

EOF

chmod +x /tmp/suricata.sh
cp /usr/bin/suricata /tmp/suricata.backup # In case you want to move back without rebooting
ln -f -s /tmp/suricata.sh /usr/bin/suricata

if [ ! -z "$APP_PID" ]; then
  killall -9 suricata
  rm -f APP_PID
fi
