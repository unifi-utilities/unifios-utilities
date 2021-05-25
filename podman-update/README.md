# Podman Update

## Features

1. Podman 3.2.0 (w/ updated conmon, and runc)
1. Persists through reboots and firmware updates
1. Full Docker / Docker Compose compatibility!
```sh
$ docker-compose -H 10.0.0.1:2375 up
Starting minecraft_1 ... done
Attaching to minecraft_1
minecraft_1  | [init] Running as uid=1000 gid=1000 with /data as 'drwxrwxr-x 4 1000 1000 240 May 25 11:55 /data'
minecraft_1  | [init] Resolved version given LATEST into 1.16.5
minecraft_1  | [init] Resolving type given VANILLA
minecraft_1  | [init] server.properties already created, skipping
minecraft_1  | [init] Checking for JSON files.
minecraft_1  | [init] Setting initial memory to 1G and max to 1G
minecraft_1  | [init] Starting the Minecraft server...
```
## Requirements

1. You have successfully set up the on boot script described [here](https://github.com/boostchicken/udm-utilities/tree/master/on-boot-script)
1. [05-install-cni-plugins.sh](../cni-plugins/05-install-cni-plugins.sh) installed

## Customization

* You can disable exposing the docker daemon by commenting out the podman service in  [01-podman-update.sh](01-podman-update.sh)
  
## Podman Build Process
* This is a custom-built binary by me.  It was cross compiled on Ubuntu-20.04 in WSL2. 
* The Makefile needs tweaks. I have supplied the [Makefile.patch](build/Makefile.patch). Apply it to a fresh [podman](https://github.com/containers/podman/) checkout
* You will need [libseccomp-dev:arm64](build/libseccomp-dev_2.2.3-3ubuntu3_arm64.deb) package installed
* You will need [go](https://golang.org/doc/install#download) > 1.12.1 installed
* Setup Cross-Compiler
```sh
sudo apt-get install libc6-arm64-cross libc6-dev-arm64-cross binutils-aarch64-linux-gnu libncurses5-dev build-essential bison flex libssl-dev bc gcc-aarch64-linux-gnu
```
* Compile
```sh
make CC="aarch64-linux-gnu-gcc" local-cross
```
## Steps

1. Copy [01-podman-update.sh](01-podman-update.sh) to /mnt/data/on_boot.d. Make sure anything needed to enable internet connectivity (wpa-supplicant, eap-proxy) runs before it
    1.  Comment out the Podman service if you do not wish to expose the Docker/Podman Daemon
1. Copy [05-install-cni-plugins.sh](../cni-plugins/05-install-cni-plugins.sh) to /mnt/data/on_boot.d
   1. Recommended: Copy [05-container-common.sh](../container-common/on_boot.d/05-container-common.sh) to /mnt/data/on_boot.d
1. Execute /mnt/data/on_boot.d/[01-podman-update.sh](01-podman-update.sh) and /mnt/data/on_boot.d/[05-install-cni-plugins.sh](../cni-plugins/05-install-cni-plugins.sh)
1. Verify Podman version
```sh
$ podman version
Version:      3.2.0-dev
API Version:  3.2.0-dev
Go Version:   go1.16.4
Git Commit:   78df4f6fb2e2a404ace69219a50652f4335b7ce1-dirty
Built:        Tue May 25 04:52:19 2021
OS/Arch:      linux/arm64
```

## Docker Compose
There is no docker-compose binary to run on the UDM yet, so please use docker-compose from a remote system and specify to run on your UDM.
    
```docker-compose -H 10.0.0.1:2375 up```

You can also use any regular docker binary and do remote management as well
```
$ docker -H 10.0.0.1:2375 ps
CONTAINER ID   IMAGE                                  COMMAND                  CREATED         STATUS       PORTS     NAMES
608a24fd121e   localhost/unifi-os:latest              "/sbin/init"             8 weeks ago     Up 8 days              unifi-os
```