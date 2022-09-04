#!/bin/sh
CONTAINER=tailscale
# Optional: If using an authket for authenticaion, put it here
AUTHKEY=""
# Optional: Extra arguments passed to 'tailscale up'
TAILSCALE_UP_ARGS=""

# Starts a container for the tailscale agent.
# There are no configuration files, and the daemon stores its state in memory
if podman container exists ${CONTAINER}; then
  podman start ${CONTAINER}
else 
  podman run -i -d --rm --net=host --name=${CONTAINER} --privileged \
    -v "/dev/net/tun:/dev/net/tun" \
    tailscale:tailscale \
    tailscaled --state=mem:
fi

# Log in to the tailnet, using the running tailscale agent
if [ -n $AUTHKEY ]; then
  podman exec ${CONTAINER} tailscale up --authkey "$AUTHKEY" $TAILSCALE_UP_ARGS
else
  podman exec ${CONTAINER} tailscale up $TAILSCALE_UP_ARGS
fi