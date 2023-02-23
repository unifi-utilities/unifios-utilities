#!/bin/bash
# Get DataDir location
DATA_DIR="/data"
case "$(ubnt-device-info firmware || true)" in
1*)
    DATA_DIR="/mnt/data"
    ;;
2*)
    DATA_DIR="/data"
    ;;
3*)
    DATA_DIR="/data"
    ;;
*)
    echo "ERROR: No persistent storage found." 1>&2
    exit 1
    ;;
esac

# Check if the directory exists
if [ ! -d "${DATA_DIR}/pihole" ]; then
    # If it does not exist, create the directory
    mkdir -p "${DATA_DIR}/pihole"
    mkdir -p "${DATA_DIR}/pihole/etc"
    echo "Directory '${DATA_DIR}/pihole' created."
else
    # If it already exists, print a message
    echo "Directory '${DATA_DIR}/pihole' already exists. Moving on."
fi
set -e

tmpdir="$(mktemp -d)"
curl -sSLo "${tmpdir}/dote" https://github.com/chrisstaite/DoTe/releases/latest/download/dote_arm64

cat >"${tmpdir}/Dockerfile" <<EOF
FROM pihole/pihole:latest
ENV DOTE_OPTS="-s 127.0.0.1:5053"
COPY dote /opt/dote
RUN chmod +x /opt/dote && mkdir -p /etc/cont-init.d/ && echo -e  "#!/bin/bash\n/opt/dote \\\$DOTE_OPTS -d\n" > /etc/cont-init.d/10-dote.sh && chmod 775 /etc/cont-init.d/10-dote.sh
EOF

podman pull pihole/pihole:latest
podman build -t pihole:latest --format docker -f "${tmpdir}/Dockerfile" "${tmpdir}"
rm -rf "${tmpdir}"

set +e

podman stop pihole
podman rm pihole
podman run -d --network dns --restart always \
    --name pihole \
    -e TZ="America/Chicago" \
    -v "${DATA_DIR}/etc-pihole/:/etc/pihole/" \
    -v "${DATA_DIR}/pihole/etc-dnsmasq.d/:/etc/dnsmasq.d/" \
    --dns=127.0.0.1 \
    --hostname pi.hole \
    -e DOTE_OPTS="-s 127.0.0.1:5053 -f 1.1.1.1 -f 1.0.0.1 -m 10" \
    -e VIRTUAL_HOST="pi.hole" \
    -e PROXY_LOCATION="pi.hole" \
    -e PIHOLE_DNS_="127.0.0.1#5053" \
    -e ServerIP="10.0.5.3" \
    -e IPv6="False" \
    pihole:latest
