# udm-utilities
A collection of things to enhance the capabilities of your Unifi Dream Machine or Dream Machine Pro. **All solutions in this repo persist through firmware upgrades!**

**Pull Requests welcome! If you use this functionality to do new cool stuff to your UDM/P please send a PR and share it with the community!"**

## General Tools
### on-boot-script
Enables init.d style scripts to run on every boot of your UDM. Includes a wpa-supplicant/eap-proxy example.  
**It allows complete customization of your UDM/P and fills the gap that config.gateway.json left behind.**

### python
If you need python3 on your UDM, generally not recommended, can always use it in unifi-os container

## DNS Providers
### dns-common
Configurations for DNS containers, both IPv4 and IPv6.  Utilizes MacVLAN CNI plugins to completely isolate the network stack.

### run-pihole
Run pihole on your UDM with podman.

### nextdns
Run NextDNS on your UDM with podman. 

### AdguardHome
Run AdguardHome on your UDM with podman.
