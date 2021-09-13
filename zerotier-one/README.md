# Run ZeroTier VPN on your UDM

## Install
1. Copy 20-zerotier.sh to /mnt/data/on_boot.d
2. Create directories for persistent Zerotier configuration

   ```
   mkdir -p /mnt/data/zerotier-one
   ```
3. Start the zeriotier container
   ```
   podman run -d \
   --name zerotier-one \
   --device=/dev/net/tun \
   --net=host \
   --cap-add=NET_ADMIN \
   --cap-add=SYS_ADMIN \
   --cap-add=CAP_SYS_RAWIO \
   -v /mnt/data/zerotier-one:/var/lib/zerotier-one \
   bltavares/zerotier
   ```
4. Join your zerotier network
   ```
   podman exec zerotier-one zerotier-cli join <your network id>
   ```
