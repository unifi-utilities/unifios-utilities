# Cloudflare Dynamic DNS 

## Features

- Update Multiple Subdomains
- Proxy your traffic through cloudflare
- Set a ttl

Complete feature list and documentation can be found [here](https://github.com/timothymiller/cloudflare-ddns)


## Requirements

1. You have successfully setup the on boot script described [here](https://github.com/boostchicken/udm-utilities/tree/master/on-boot-script)
2. You must have a cloudflare profile with at least one domain.
3. You must have a valid cloudflare api token with correct permissions (see [complete documentation](https://github.com/timothymiller/cloudflare-ddns) for details)

## Customization

Update [config.json](configs/config.json) with the following options:
- your cloudflare api token
- your zone id
- each subdomain you'd like to point at your udm-pro
- Set the proxied flag if you'd like cloudflare to proxy the records
- Set the ttl value you'd like for your records

## Steps

2. Make a directory for your configuration

    ```sh
    mkdir -p /mnt/data/cloudflare-ddns
    ```

3. Create a [cloudflare-ddns configuration](configs/config.json) in `/mnt/data/cloudflare-ddns` and update the configuration to meet your needs.
4. Copy [30-cloudflare-ddns.sh](on_boot.d/30-cloudflare-ddns.sh) to `/mnt/data/on_boot.d`.
5. Execute /mnt/data/on_boot.d/[30-cloudflare-ddns.sh](on_boot.d/30-cloudflare-ddns.sh)
7. Execute `podman logs cloudflare-ddns` to verify the continer is running without error (ipv6 warnings are normal).

### Useful commands

```sh
# view cloudflare-ddns logs to verify the continer is running without error (ipv6 warnings are normal).
podman logs cloudflare-ddns
```

