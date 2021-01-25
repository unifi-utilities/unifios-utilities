# Run Homebridge on your UDM

### Features
1. Run [Homebridge](https://homebridge.io/) on your UDM.
2. Integrate Unifi Protect cameras in HomeKit via `homebridge-unifi-protect`.
3. Persists through reboots and firmware updates.

### Requirements
1. You have successfully setup the on boot script described [here](https://github.com/boostchicken/udm-utilities/tree/master/on-boot-script).
2. You have applied [container-common](https://github.com/boostchicken/udm-utilities/tree/master/container-common) change to prevent UDM storage to fill up with Homebridge logs and addon error messages that can move fast.

### Customization

- Update [90-homebridge.conflist](cni/90-homebridge.conflist) to match your network:
  - Change `"bridge": "br0"` to the appropriate VLAN for your network.
  - Update `"subnet"` and `"gateway"` to match that VLAN.
  - If you want a specific IP assigned, update `"rangeStart"` and `"rangeEnd"`. Otherwise those properties can be deleted.

### Steps

1. `mkdir -p /mnt/data/homebridge/run`
2. Copy [25-homebridge.sh](on_boot.d/25-homebridge.sh) to `/mnt/data/on_boot.d`.
3. Copy [90-homebridge.conflist](cni/90-homebridge.conflist) to `/mnt/data/podman/cni`. This will create the podman network that bridges the container to your VLAN.
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
        -v "/mnt/data/homebridge/:/homebridge/" \
        -v "/mnt/data/homebridge/run/:/run/" \
        oznu/homebridge:latest
    ```

5. Access the Homebridge UI based on the IP you assigned, like [http://192.168.1.20/](http://192.168.1.20/).
6. If using the UDM Pro, the `homebridge-unifi-protect` plugin can be installed via the Homebridge UI to integrate Unifi Protect cameras.
