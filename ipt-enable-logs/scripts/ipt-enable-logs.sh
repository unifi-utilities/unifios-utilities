#!/bin/sh

set -e

docker run -it --rm -v /mnt/data/scripts/ipt-enable-logs:/src -w /src --network=none golang:1.17.3 go build -v -o /src/ipt-enable-logs /src >&2

/mnt/data/scripts/ipt-enable-logs/ipt-enable-logs
