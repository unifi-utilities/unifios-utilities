# ToDo

* provide a ssh proxy for udm-boot to break out the container.
  reuse existing from unifi-os ssh_proxy or a customer one. if we reuse it, we need a way to reload the port on unifi-os restart (would require to mount the dir /var/run/ instead of the file /var/run/ssh_proxy_port
* move udm-boot-services service into the udm-boot container (minimize udm-boot footprint in the unifi-os).
  requires the ssh proxy solved
* find a more clean way to preserve services? currently mounting the whole /etc/systemd/system dir.
* if we will provide cockpit in this package, put it in a container and include at least cockpit-podman package
