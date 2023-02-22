# Tailscale

Run Tailscale in a container on your Unifi Dream Machine.
In combination with the DNS modules, setting up a Tailscale exit node on the UDM Pro can be quite powerful.
Additionally, the UDM is well positioned to add a tailscale subnet router to permit remote access to the manged network.

## Prerequisites

Follow the instructions and set up the scripts in these directories (in order) before continuing further:

1. `on-boot-script`
2. `container-common`
3. `cni-plugins`
4. (optional, but recommended if you want to set up an exit node and benefit from ad-blocking) `dns-common` followed by your favorite DNS server such as `run-pihole` or `AdguardHome`

## Installation

1. Copy `on_boot.d/20-tailscale.sh` to `/data/on_boot.d/20-tailscale.sh`.
2. Make sure the boot script is executable with `chmod +x /data/on_boot.d/20-tailscale.sh`.

## Tailscale Configuration

After installing the boot script, you will want to set up the included shell alias and check network connectivity before continuing.

1. Run `/data/on_boot.d/20-tailscale.sh alias` to print a helpful shell alias to the terminal, inside a shell comment.
2. Add the alias to your running session, after which you can run `tailscale status` or `tailscale netcheck` from the host shell to make sure the running tailscale agent is healthy and has a good network connection.
3. `/data/on_boot.d/20-tailscale.sh status` will also perform status checks, if the alias setup isn't working for some reason.

How to proceed from here is largely up to you. It is possible to authenticate by simply running `tailscale up` (if you installed the shell alias) and doing most of the rest of the configuration in the admin console. You will likely want to provide additional options to `tailscale up` to use an auth key, advertise tags or subnet routes, or other configuration.
