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

## Setup
1. Edit `on_boot.d/20-tailscale.sh` to set an auth key, add options for `tailscale up`, or make other changes as desired.
2. Copy `on_boot.d/20-tailscale.sh` to `/mnt/data/on_boot.d/20-tailscale.sh`.
3. Make sure the boot script is executable with `chmod +x /mnt/data/on_boot.d/20-tailscale.sh`.
4. Run the boot script to start the tailscale agent. You should see your new node appear in the Tailscale console. 