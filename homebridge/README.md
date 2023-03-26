# Run Homebridge on your UDM

### Features

1. Run [Homebridge](https://homebridge.io/) on your UDM(P).
2. Integrate Unifi Protect cameras in HomeKit via `homebridge-unifi-protect`.
3. Persists through reboots and firmware updates.

### Requirements

1. You have successfully setup the on boot script described [here](https://github.com/unifi-utilities/unifios-utilities/tree/main/on-boot-script).
2. You have applied [container-common](https://github.com/unifi-utilities/unifios-utilities/tree/main/container-common) change to prevent UDM storage to fill up with Homebridge logs and addon error messages that can move fast.
3. You have applied [cni-plugins](https://github.com/unifi-utilities/unifios-utilities/tree/main/cni-plugins "cni-plugins") to setup for cni configeration. (You dont need the configeration files, just place the script in the on boot folder.)

### Steps

1. Type this command: `mkdir -p /data/homebridge/run`
2. Copy [25-homebridge.sh](on_boot.d/25-homebridge.sh) to `/data/on_boot.d`. To do this, cd into `/data/on_boot.d`, then type `vim 25-homebridge.sh` then go to [this page](https://raw.githubusercontent.com/unifi-utilities/unifios-utilities/main/homebridge/on_boot.d/25-homebridge.sh "this page") and copy everything using CTRL + A and then CTRL + C and then paste it into vim then click ESC and then type `:x` then click the enter key.
3. Copy [90-homebridge.conflist](cni/90-homebridge.conflist) to `/data/podman/cni`. This will create the podman network that bridges the container to your VLAN. To do this, cd into `/data/podman/cni` and type `vim 90-homebridge.conflist` then go to [this page](https://raw.githubusercontent.com/unifi-utilities/unifios-utilities/main/homebridge/cni/90-homebridge.conflist "this page") and the press CTRL + A and then CTRL + C and then paste it into vim and click ESC and then type `:x` then click the enter key.
4. Run the Homebridge docker container. Change the timezone (`-e TZ`) to match your timezone, and DNS (`--dns`) to match your VLAN gateway.

   ```shell script
    podman run -d --restart always \
       --privileged \
       --name homebridge \
       --net homebridge \
       --dns 192.168.1.1 \
       --dns-search lan \
       -e TZ=America/Chicago \
       -e PGID=0 -e PUID=0 \
       -e HOMEBRIDGE_CONFIG_UI=1 \
       -e HOMEBRIDGE_CONFIG_UI_PORT=80 \
       -v "/data/homebridge/:/homebridge/" \
       -v "/data/homebridge/run/:/run/" \
       oznu/homebridge:latest
   ```

5. Access the Homebridge UI based on the IP you assigned, like [http://192.168.1.20/](http://192.168.1.20/).
6. If using the UDM Pro, the `homebridge-unifi-protect` plugin can be installed via the Homebridge UI to integrate Unifi Protect cameras.

### Customization

- Update [90-homebridge.conflist](cni/90-homebridge.conflist) to match your network:
  - Change `"bridge": "br0"` to the appropriate VLAN for your network.
  - Update `"subnet"` and `"gateway"` to match that VLAN.
  - If you want a specific IP assigned, update `"rangeStart"` and `"rangeEnd"`. Otherwise those properties can be deleted.
