#!/bin/sh

set -e

tmpdir="$(mktemp -d)"
curl -sSLo "${tmpdir}/dote" https://github.com/chrisstaite/DoTe/releases/latest/download/dote_arm64

cat > "${tmpdir}/Dockerfile" <<EOF
FROM pihole/pihole:latest
ENV DOTE_OPTS="-s 127.0.0.1:5053"
COPY dote /opt/dote
RUN chmod +x /opt/dote && echo -e  "#!/bin/sh\n/opt/dote \\\$DOTE_OPTS -d\n" > /etc/cont-init.d/10-dote.sh
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
    -v "/mnt/data/etc-pihole/:/etc/pihole/" \
    -v "/mnt/data/pihole/etc-dnsmasq.d/:/etc/dnsmasq.d/" \
    --dns=127.0.0.1 \
    --hostname pi.hole \
    -e DOTE_OPTS="-s 127.0.0.1:5053 -m 10" \
    -e VIRTUAL_HOST="pi.hole" \
    -e PROXY_LOCATION="pi.hole" \
    -e PIHOLE_DNS_="127.0.0.1#5053" \
    -e ServerIP="10.0.5.3" \
    -e IPv6="False" \
    pihole:latest
