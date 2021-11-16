#!/bin/sh

CONTAINER=node-exporter

# Starts a Prometheus node-exporter container that is deleted after it is stopped.
if podman container exists "${CONTAINER}"; then
  podman start "${CONTAINER}"
else
  podman run -d --rm --name "${CONTAINER}" --net="host" --pid="host" -v "/:/host:ro,rslave" quay.io/prometheus/node-exporter:latest --path.rootfs=/host
fi
