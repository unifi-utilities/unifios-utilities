#!/bin/bash
CONTAINER=tailscale

# Starts a container for the tailscale agent.
# There are no configuration files, and the daemon stores its state in memory
start() {
  if podman container exists ${CONTAINER}; then
    podman start ${CONTAINER}
  else 
    podman run -d --rm \
      --net=podman \
      --name=${CONTAINER} \
      --privileged \
      -v "/dev/net/tun:/dev/net/tun" \
      tailscale/tailscale \
      tailscaled --state=mem:
      # Changing sysctls inside the container to support running an exit node
    cat <<'INIT' | podman exec --privileged ${CONTAINER} /bin/bash
echo '1' > /proc/sys/net/ipv4/ip_forward ;
echo '1' > /proc/sys/net/ipv6/conf/all/forwarding ;
INIT
  fi
}

# Print the status of the tailscale connection, as well as the network status
status() {
  if podman container exists ${CONTAINER}; then
    podman exec -it --privileged ${CONTAINER} tailscale status
    podman exec -it --privileged ${CONTAINER} tailscale netcheck
  fi
}

# Because daemon state is in memory, stopping the container removes the node
# from the network.
stop() {
  podman stop ${CONTAINER}
}

# Really only useful during debugging, saves some typing at the cost of 
# additional container creation.
clean() {
  podman rm ${CONTAINER} --force
}

# Print an alias to stdout to make interacting with tailscale easier, post-start
# in case debugging needs to happen
alias() {
  echo "# alias tailscale='podman exec -it --privileged ${CONTAINER} tailscale '"
}

# This function shows a usage message, in case something unexpected happened
usage() {
  echo "Usage: $0 OPERATION"
  echo ""
  echo "This script manages the lifecycle of a Tailscale agent container."
  echo "OPERATION can be one of the following commands:"
  echo "  start     start the Tailscale agent container"
  echo "  stop      stop the container"
  echo "  status    get the auth status and network status of the Tailscale container"
  echo "  clean     stop and delete the container, helpful when making config changes"
  echo "  alias     print a helpful shell alias which can be used to interact with tailscale from the host"
  echo "  help      show this help"
  echo ""
}

case $1 in 
  start)
    start
    ;;
  status)
    status
    ;;
  stop)
    stop
    ;;
  clean)
    stop
    clean
    ;;
  alias)
    alias
    ;;
  [hH-]*)
    # This is supposed to match 'help', 'Help', '-h', etc
    usage
    ;;
  *)
    # If the script is called with no arguments, such as on startup,
    # start the container
    start
    ;;
esac