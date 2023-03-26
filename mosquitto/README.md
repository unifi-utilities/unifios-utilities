# [Eclipse Mosquitto™](https://mosquitto.org) on Ubiquiti Unifi Dream Machine (Pro)

> Run the MQTT message broker Eclipse Mosquitto™ on your Unifi Dream Machine (Pro).

## Prerequisities

- Working **`on_boot.d`** setup (check [unifi-utilities/unifios-utilities#on-boot-script](https://github.com/unifi-utilities/unifios-utilities/tree/main/on-boot-script) for instructions)
- A VLAN network (you can use one you are already using)

**Recommended**

- Use [container-common](../container-common/README.md) to prevent growing disk usage from accumulating logs

**Optional**

- Port forwarding, ie. WAN -> [MOSQUITTO_IP] (TCP/1883) if needed

**Note**  
Throughout this guide I'm using `VLAN 20` with gateway `10.0.20.1/24` as an example; Mosquitto's IP will be `10.0.20.4`.  
_Adjust according to your setup._

## Setup

1. First, lets create the folder structure we'll be working with.

   `$ mkdir -p /data/mosquitto/config /data/mosquitto/data`

   This is where Mosquitto's configuration file and data ("persistence database"; if enabled) will live.  
   If you're unsure on how to configure mosquitto, use the provided barebone config [`config/mosquitto.conf`](config/mosquitto.conf) to get it initially running.

2. **Optional:** Customize [`on_boot.d/45-mosquitto.sh`](on_boot.d/45-mosquitto.sh) to your setup and copy to `/data/on_boot.d/`.
   Most likely you'll need to mark the script as executable, this will do the trick:

   `$ chmod a+x /data/on_boot.d/45-mosquitto.sh`

3. Then take a loot at [`cni/45-mosquitto.conflist`](cni/45-mosquitto.conflist) and make sure it matches your previously defined configuration; then place it in `/data/podman/cni/`

4. Run boot script (to create the mosquitto network set it's ip routes)

   `$ sh /data/on_boot.d/45-mosquitto.sh`

   It fail when trying to run the container, but thats okay, its just for setting op needed configuration before initial image run.  
   The script will also create a [minimal configuration](config/mosquitto.conf) for Mosquitto in `/data/mosquitto/config/`, _**only if it doesn't already exist**_.

   > **Note:** You can use this config to get everything started, but I highly recommend securing your instance with authentication (links to the offical documentation & other resources are at the bottom)

5. Register the container with podman:

   ```shell
   $ podman run -d --network mosquitto \
       --restart always \
       --security-opt=no-new-privileges \
       --name mosquitto \
       --hostname mosquitto.local \
       -e "TZ=Europe/Berlin" \
       -v /data/mosquitto/config/:/mosquitto/config \
       -v /data/mosquitto/data/:/mosquitto/data \
       eclipse-mosquitto:latest
   ```

6. Run boot script again and we are done!

   `$ sh /data/on_boot.d/45-mosquitto.sh`

> You should now be able to connect with any MQTT client to Mosquitto, in my case `mqtt://10.0.20.4:1883`

## Commands

**Updates**  
To update container image to its latest version, first delete the current container (`$ podman stop mosquitto && podman rm mosquitto`) and follow through setup steps 5. & 6.

**Logs**  
If you want to know what mosquitto is doing, run `$ podman logs -f mosquitto` to follow the logs.

## Relevant Links

- [Eclipse Mosquitto Homepage](https://mosquitto.org)
- [mosquitto.conf man page](https://mosquitto.org/man/mosquitto-conf-5.html)
- [Setting up Authentication in Mosquitto MQTT Broker](https://medium.com/@eranda/setting-up-authentication-on-mosquitto-mqtt-broker-de5df2e29afc)
- [eclipse-mosquitto on Docker-Hub](https://hub.docker.com/_/eclipse-mosquitto/)

## Credits

Huge thanks to @boostchicken for his incredible work on [unifios-utilities](https://github.com/unifi-utilities/unifios-utilities) and all contributors of this repo!
