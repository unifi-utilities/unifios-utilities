IMAGE=haproxy:latest
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
podman pull $IMAGE
podman stop haproxy
podman rm haproxy
podman run -d --net=host --restart always \
  --name haproxy \
  --hostname ha.proxy \
  -v "${DATA_DIR}/haproxy/:/usr/local/etc/haproxy/" \
  $IMAGE
