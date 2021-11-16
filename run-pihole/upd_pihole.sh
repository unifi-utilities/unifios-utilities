
# Change to boostchicken/pihole:latest for DoH
# Change to boostchicken/pihole-dote:latest for DoTE
IMAGE=pihole/pihole:latest

podman pull $IMAGE
podman stop pihole
podman rm pihole
podman run -d --network dns --restart always \
    --name pihole \
    -e TZ="America/Chicago" \
    -v "/mnt/data/etc-pihole/:/etc/pihole/" \
    -v "/mnt/data/pihole/etc-dnsmasq.d/:/etc/dnsmasq.d/" \
    --dns=127.0.0.1 \
    --dns=1.1.1.1 \
    --dns=1.0.0.1 \
    --hostname pi.hole \
    -e VIRTUAL_HOST="pi.hole" \
    -e PROXY_LOCATION="pi.hole" \
    -e ServerIP="10.0.5.3" \
    -e IPv6="False" \
    $IMAGE
