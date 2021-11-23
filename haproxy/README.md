# Run haproxy on your UDM

## Features

1. Load balance services on your UDM, because why not?.
2. Persists through reboots and firmware updates.

## Requirements

1. You have successfully setup the on boot script described [here](https://github.com/boostchicken/udm-utilities/tree/master/on-boot-script)
2. You have to have services you want to load-balance, an example would be a multi-master k3s cluster.

## Steps

1. Pull your image with `podman pull docker.io/library/haproxy`.
1. (Optional) Configure a network using the generic cni network [20-dns.conflist](../cni-plugins/20-dns.conflist) and update its values to reflect your environment
1. Copy [50-haproxy.sh](./50-haproxy.sh) to `/mnt/data/on_boot.d/50-haproxy.sh`.
1. Create a persistant directory and config for haproxy to use:

    ```sh
    mkdir -p /mnt/data/haproxy
    touch /mnt/data/haproxy/haproxy.cfg
    ```

1. Add your config to `/mnt/data/haproxy/haproxy.cfg`. Each configuration is unique, so check out some resouces like [haproxy.com](https://www.haproxy.com/documentation/hapee/latest/configuration/config-sections/) for basics.
1. Run `/mnt/data/on_boot.d/50-haproxy.sh`

## Upgrading Easily (if at all)

1. Edit [update-haproxy.sh](./update-haproxy.sh) to use the same command you used at installation (if changed).
2. Copy the [update-haproxy.sh](./update-haproxy.sh) to `/mnt/data/scripts`
3. Anytime you want to update your installation, simply run `/mnt/data/scripts/update-haproxy.sh`
