# How to Create a Custom Container on UnifiOS 3.x+

This is a guide that shows you how to create your own container on UnifiOS 3.0+, and how to install custom services in your container (such as pihole or adguard home).

Starting with UnifiOS 3.0, podman/docker support has been removed due to a kernel change. However, you can still create a container with systemd-nspawn, which is what this guide will focus on. 

## Table of Contents

1. [Instructions](#instructions)  
    * [Step 1. Create the Container](#step-1-create-the-container)
    * [Step 2. Configure the Container](#step-2-configure-the-container)
    * [Step 2A. Configure the Container To Use An Isolated MacVLAN Network](#step-2a-configure-the-container-to-use-an-isolated-macvlan-network)
    * [Step 3. Configure Persistence Across Firmware Updates](#step-3-configure-persistence-across-firmware-updates)
    * [Step 4. Install Custom Services](#step-4-install-custom-services)
2. [FAQ](#faq)

## Instructions

### Step 1. Create the Container

The following commands are all perfomed on the Unifi router in SSH. 

1. We first need to install systemd-container and debootstrap. We will use debootstrap to create a directory with a base debian system, and then use systemd-nspawn to boot the container. 

    ```sh
    apt -y install systemd-container debootstrap
    ```

2. Next, we use debootstrap to create a directory called `debian-custom` with a base debian system in `/data/custom/machines`.

    ```sh
    mkdir -p /data/custom/machines
    cd /data/custom/machines
    debootstrap --include=systemd,dbus unstable debian-custom
    ```
    * This process can take up to 10 minutes to download and install all the packages.
    * The container folder will be 390MB after installation, but can increase to 1GB+ after installing many services (storage management is up to you).
    * Note: Instead of debootstrap, you can also use pacstrap or other distributions' tools to create an Arch Linux, Fedora, or other container instead of a debian container (see [examples here](https://www.freedesktop.org/software/systemd/man/systemd-nspawn.html#Examples)).

3. Finally, let's bring up a shell on this container, set the root password, and enable the networking service. Run each command one-by-one.

    ```sh
    systemd-nspawn -M debian-custom -D /data/custom/machines/debian-custom
    passwd root
    systemctl enable systemd-networkd
    echo "nameserver 1.1.1.1" > /etc/resolv.conf
    echo "debian-custom" > /etc/hostname
    exit
    ```
    
    * The first command should put you in a shell in the container. If it doesn't work, something went wrong.
    * Note the password will be hidden when you are typing it out in the `passwd root` command, and you will be asked to type it twice.
    * We also set the default nameserver to 1.1.1.1 in resolv.conf. You can change this to your own DNS or omit this command if you plan to configure the DNS later.
    * The hostname can be set to whatever you want, here debian-custom is used as an example. 

### Step 2. Configure the Container

Now that the container is created, let's configure it. Make sure you are back on the host OS and not in the container.

1. First, we will link the container to `/var/lib/machines` so we can control it with `machinectl`.

    ```sh
    mkdir -p /var/lib/machines
    ln -s /data/custom/machines/debian-custom /var/lib/machines/
    ```

2. Next, we will create a `debian-custom.nspawn` file in `/etc/systemd/nspawn` to configure parameters for the container (such as network, bind mounts, etc). Here I use vim to create the file as a personal preference.

    ```sh
    mkdir -p /etc/systemd/nspawn
    vim /etc/systemd/nspawn/debian-custom.nspawn
    ```
    
    * For a container that has access to all the host network interfaces and full capabilities to do anything to the system, here is an example nspawn configuration file. Note it is important to set `Boot=on` so systemd boots up inside the container. 

        ```ini
        [Exec]
        Boot=on
        Capability=all
        ResolvConf=off

        [Network]
        Private=off
        VirtualEthernet=off
        ```
    
    * For a more isolated container configured with a macvlan bridge, follow [Step 2A](#step-2a-configure-the-container-to-use-an-isolated-macvlan-network) below instead before running the container. 
    * For other options, see the nspawn manpage [here](https://www.freedesktop.org/software/systemd/man/systemd.nspawn.html).

3. After you've configured your nspawn file, let's boot up the container and see if it works.

    ```sh
    machinectl start debian-custom
    machinectl enable debian-custom
    ```
    
    * If the container booted up, you can check `machinectl status debian-custom` for information (hint: press 'q' to exit the status log). 
    * The second enable command will enable the container to start on boot. 
    
4. Now that the container is running, we should be able to open a shell or login to it. 

  * Typing `machinectl shell debian-custom` should open a shell to the machine and bypass login. Typing `exit` in this shell will exit back to the host Unifi OS. 
  * Typing `machinectl login debian-custom` will give you a login prompt like a normal Linux system. In most cases, you can just use `machinectl shell` to bypass the login for easier access. If you do use the login instead of the shell, you can exit the container by holding the `Ctrl` key and pressing the `]` key 3 times. 

5. Now that you have access to your own container, you can install whatever services you want within it like a normal Linux system ([see examples below](#step-4-install-custom-services)). Make sure you ran `machinectl enable debian-custom` so the container starts on boot. 

### Step 2A: Configure the Container to use an Isolated MacVLAN Network

This configuration is only needed if you want to isolate the container's network with a macvlan bridge. The following steps are all performed on the host OS. 

1. Download the [10-setup-network.sh](scripts/10-setup-network.sh) script to `/data/on_boot.d` and configure it with your VLAN and IPs for your container and gateway. This script will create a brX.mac interface as a gateway bridge for containers to communicate with. 

    ```sh
    mkdir -p /data/on_boot.d && cd /data/on_boot.d
    curl -LO https://raw.githubusercontent.com/peacey/unifios-utilities/nspawn/nspawn-container/scripts/10-setup-network.sh
    vim 10-setup-network.sh
    ```

    * Modify `VLAN` to an existing VLAN network that you want your container to be on. The default is VLAN 5. Make sure this VLAN network is created in Unifi first with a unique subnet and IP (do not use the same IP as you will use for IPV4_IP or IPV4_GW in this script).
    * Modify `IPV4_GW` to set the gateway interface's IP. The default is 10.0.5.1/24, but you can use whatever subnet you want as long as it's different than any Unifi subnet. 
    * Modify `IPV4_IP` to your preferred container IP. The default is 10.0.5.3, but you can use whatever you want as long as its on the same subnet as the gateway subnet `IPV4_GW`. 
    * Also modify `IPV6_GW` and `IPV6_IP` if you need IPV6 support. Leave them empty for no IPV6 support. 

2. Create or modify your `/etc/systemd/nspawn/debian-custom.nspawn` file with the following parameters. This will tell nspawn to isolate the network and create a macvlan interface in the container from our VLAN bridge. This interface will be called mv-br5.

    ```ini
    [Exec]
    Boot=on
    ResolvConf=off

    [Network]
    MACVLAN=br5
    ```

    * Change br5 to brX where X = VLAN number you used in `10-setup-network.sh`. 

3. Configure your container to set the IP and gateway you defined in `10-setup-network.sh` by creating a network file in the folder `/etc/systemd/network` under your container's directory. Name this file `mv-brX.network` where X = VLAN number you used (e.g. `mv-br5.network`).

    ```sh
    cd /data/custom/machines/debian-custom/etc/systemd/network
    vim mv-br5.network
    ```

    * The following is an example configuration based on the default settings in `10-setup-network.sh`.

        ```ini
        [Match]
        Name=mv-br5

        [Network]
        IPForward=yes
        Address=10.0.5.3/24
        Gateway=10.0.5.1
        Address=fd62:89a2:fda9:e23::3/64
        Gateway=fd62:89a2:fda9:e23::1
        ```
        
    * Make sure to change `Name` to the correct VLAN.
    * Change `Address` and `Gateway` accordingly if you changed the settings in `10-setup-network.sh`.
    * You can remove the last 2 lines with IPv6 addresses if you don't need IPv6. 

4. Run the `10-setup-network.sh` script, start the container, open a shell on the container, and check the network. 

    ```sh
    chmod +x /data/on_boot.d/10-setup-network.sh
    /data/on_boot.d/10-setup-network.sh
    machinectl reboot debian-custom
    machinectl shell debian-custom
    ip addr show
    ping -c4 1.1.1.1
    ```
  
    * You should see the correct IP defined on mv-br5. If no IP has been assigned, make sure you enabled and started the systemd-networkd service and check again: `systemctl enable --now systemd-networkd`
    * If you still don't see any IP on mv-br5, then double-check you're using the correct VLAN and put the configuration in the correct location. You can also check `journalctl -eu systemd-networkd` for any errors.
    * If pinging 1.1.1.1 doesn't work from within the container, double-check you set the correct container IP in your 10-setup-network.sh. 
    
5. The script `10-setup-network.sh` in `/data/on_boot.d` needs to be started on boot. 
    * If you've installed the udm-boot service, it should automatically run any scripts in `/data/on_boot.d` and no further setup is needed. 
    * If you prefer not to use udm-boot and instead use your own systemd boot service, [here is an example systemd service](scripts/setup-network.service) to run this script at boot. Save it to `/etc/systemd/system/setup-network.service` in the host OS (not container) and then enable it with `systemctl enable setup-network`. 

### Step 3: Configure Persistence Across Firmware Updates

When the firmware is updated, `/data` (which contains our container storage) and `/etc/systemd` (which contains our boot scripts) are preserved, but `/var` and `/usr` is deleted by the firmware update script. Any additional debian packages that are installed in the host OS like systemd-container are also deleted. This means we need to reinstall the systemd-container package and re-link our container to /var/lib/machines (for machinectl access) when the firmware is upgraded. This can be accomplished with a simple boot script that checks to see if this package is installed on boot.

1. Download the [0-setup-system.sh](scripts/0-setup-system.sh) script into /data/on_boot.d.

    ```sh
    mkdir -p /data/on_boot.d && cd /data/on_boot.d
    curl -LO https://raw.githubusercontent.com/peacey/unifios-utilities/nspawn/nspawn-container/scripts/0-setup-system.sh
    chmod +x /data/on_boot.d/0-setup-system.sh
    ```
    
2. Download the backup dpkg package files for systemd-container and dependencies into `/data/custom/dpkg`. These packages will only be used as a backup install in case the Internet is down after the first boot after an update. 

    ```sh
    mkdir -p /data/custom/dpkg && cd /data/custom/dpkg
    apt download systemd-container libnss-mymachines debootstrap arch-test
    ```
    
3. The script `0-setup-system.sh` in `/data/on_boot.d` needs to be started on boot. 
    * If you've installed the udm-boot service, it should automatically run any scripts in `/data/on_boot.d` and no further setup is needed. 
    * If you prefer not to use udm-boot and instead use your own systemd boot service, [here is an example systemd service](scripts/setup-system.service) to run this script at boot. Save it to `/etc/systemd/system/setup-system.service` in the host OS (not container) and then enable it with `systemctl enable setup-system`. 

### Step 4: Install Custom Services

Services can be installed in the container like any linux system. For debian containers, you can use apt or other manual methods. Follow the Debian/Linux guide for your particular software that you want to install. 

* Common examples
    * [Pi-Hole](examples/pihole/README.md)
    * [AdGuard Home](examples/adguardhome/README.md)

## FAQ

1. How do I access a folder from the host OS in the container (e.g. the /data directory)?

    * Edit your `.nspawn` config file and add the following `[Files]` section. You can specify multiple `Bind=` or `BindReadOnly=` lines to bind mount multiple directories. See [nspawn manpage](https://www.freedesktop.org/software/systemd/man/systemd.nspawn.html#Bind=) for more details.

        ```ini
        [Files]
        Bind=/data:/data
        ```

2. I am getting security errors trying to run certain privileged commands in the container.

    * Edit your `.nspawn` config file and add `Capability=all` under the `[Exec]` section to unlock all security capablitlites. You can also permit or restrict capabilities for enhanced security (see the [nspawn manpage](https://www.freedesktop.org/software/systemd/man/systemd.nspawn.html#Capability=) for more information).

3. Some programs complain of a missing /lib/modules folder and can't access kernel modules. 

    * Edit your `.nspawn` config file and add `BindReadOnly=/lib/modules` to the `[Files]` section. This will bind mount the /lib/modules folder from the host OS. You might also want to try unlocking all capabilitites or specific ones (as in the above question) if you're still having issues with permissions using certain modules. 

4. iptables doesn't work in the container after I installed it.

    * You need to use iptables-legacy and not iptables-nft because the host OS is still using the legacy iptables. If using a Debian container, you can switch to the legacy iptables with the following commands executed from within the container. Also, you won't be able to see or modify the host's iptables entries if you're using a private/macvlan network for the container.
    
        ```sh
        update-alternatives --set iptables /usr/sbin/iptables-legacy
        update-alternatives --set ip6tables /usr/bin/ip6tables-legacy
        ```

