IMAGE=haproxy:latest

podman pull $IMAGE
podman stop haproxy
podman rm haproxy
podman run -d --net=host --restart always \
  --name haproxy \
  --hostname ha.proxy \
  -v "/data/haproxy/:/usr/local/etc/haproxy/" \
  $IMAGE
