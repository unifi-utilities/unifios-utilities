podman pull haproxy
podman stop haproxy
podman rm haproxy
podman run -d --net=host --restart always \
  --name haproxy \
  --hostname ha.proxy \
  -v "/mnt/data/haproxy/:/usr/local/etc/haproxy/" \
  haproxy:latest