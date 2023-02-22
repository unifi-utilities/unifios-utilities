# Cloudflare Dynamic DNS

## Features

- Update Multiple Subdomains
- Proxy your traffic through cloudflare
- Set a ttl

Complete feature list and documentation can be found [here](https://github.com/timothymiller/cloudflare-ddns)

## Requirements

1. You have successfully setup the on boot script described [here](https://github.com/unifi-utilities/unifios-utilities/tree/main/on-boot-script)
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

1. Make a directory for your configuration, check if you have `/mnt/data/` or `/data/` and adjust accordingly.

   ```sh
   mkdir -p /data/cloudflare-ddns
   ```

2. Create a [cloudflare-ddns configuration](configs/config.json) in `/data/cloudflare-ddns` and update the configuration to meet your needs.
3. Copy [30-cloudflare-ddns.sh](on_boot.d/30-cloudflare-ddns.sh) to `/data/on_boot.d`.
. Execute /data/on_boot.d/[30-cloudflare-ddns.sh](on_boot.d/30-cloudflare-ddns.sh)
5. Execute `podman logs cloudflare-ddns` to verify the continer is running without error (ipv6 warnings are normal).

### Useful commands

```sh
# view cloudflare-ddns logs to verify the continer is running without error (ipv6 warnings are normal).
podman logs cloudflare-ddns
```
