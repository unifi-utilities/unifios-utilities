# [Eclipse Mosquitto™](https://mosquitto.org) on Ubiquiti Unifi Dream Machine (Pro)

> Run the MQTT message broker Eclipse Mosquitto™ on your Unifi Dream Machine (Pro).

## Prerequisities

- Working **`on_boot.d`** setup (check [unifi-utilities/unifios-utilities#on-boot-script](https://github.com/unifi-utilities/unifios-utilities/tree/main/on-boot-script) for instructions)
- A VLAN network (you can use one you're already using)

#### Optional:

- [container-common](../container-common/README.md) to prevent growing disk usage from accumulating logs
- Port forwarding, ie. WAN -> 10.0.20.4 (TCP/1883) if needed

> **Note:** Throughout this guide I'm using `VLAN 20` with gateway `10.0.20.1/24`, Mosquitto's IP will be `10.0.20.4`.
> Adjust according to your setup.

## Setup

1. First, lets create the folder structure we'll be working with.

    `$ mkdir -p /mnt/data/mosquitto/data /mnt/data/mosquitto/config`

2. Customize [`on_boot.d/45-mosquitto.sh`](on_boot.d/45-mosquitto.sh) to your needs and copy to `/mnt/data/on_boot.d/`.  
    Most likely you'll need to mark the script as executable, this will do the trick:

    `$ chmod a+x /mnt/data/on_boot.d/45-mosquitto.sh`

3. Also edit [`cni/45-mosquitto.conflist`](cni/45-mosquitto.conflist) according your configuration and copy to `/mnt/data/podman/cni/`.

4. Run boot script (to create update network and create CNI configuration for container)

    `$ sh /mnt/data/on_boot.d/45-mosquitto.sh`

    It fail when trying to run the container, but thats okay, its just for setting op needed configuration before initial image run.  
    The script will also create a [bare-metal configuration](config/mosquitto.conf) for Mosquitto in `/mnt/data/mosquitto/config/`.  

    > **Note:** You can use this config to get everything started, but I highly recommend securing your instance with authentication (links to the offical documentation & other resources are at the bottom)

5. Register the container with podman:

    ```shell
    $ podman run -d --network mosquitto \
        --restart always \
        --security-opt=no-new-privileges \
        --name mosquitto \
        --hostname mosquitto.local \
        -e "TZ=Europe/Berlin" \
        -v /mnt/data/mosquitto/config/:/mosquitto/config \
        -v /mnt/data/mosquitto/data/:/mosquitto/data \
        eclipse-mosquitto:latest
    ```

6. Run boot script again and we are done!

    `$ sh /mnt/data/on_boot.d/45-mosquitto.sh`

> You should now be able to connect with any MQTT client to Mosquitto, in my case `mqtt://10.0.20.4:1883`

## Commands

#### Updates

To update container image, simple do `$ podman stop mosquitto && podman rm mosquitto` and run boot script again.

#### Logs

If you want to know what Mosquitto is doing, run `$ podman logs -f mosquitto` to follow the logs.

## References

- [Eclipse Mosquitto Homepage](https://mosquitto.org)
- [mosquitto.conf man page](https://mosquitto.org/man/mosquitto-conf-5.html)
- [Setting up Authentication in Mosquitto MQTT Broker](https://medium.com/@eranda/setting-up-authentication-on-mosquitto-mqtt-broker-de5df2e29afc)

## Credits

Huge thanks to @boostchicken and his incredible work on [unifios-utilities](https://github.com/unifi-utilities/unifios-utilities)!  

Guide based upon the incredible contributors of [boostchicken/unifios-utilities](https://github.com/unifi-utilities/unifios-utilities)!
