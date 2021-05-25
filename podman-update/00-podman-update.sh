#!/bin/sh

mkdir -p /mnt/data/podman-update

PODMAN_DL=/mnt/data/.cache/podman
CONMON_DL=/mnt/data/.cache/conmon
SECCOMP=/usr/share/container/seccomp.json

if [ ! -f CONMON_DL ]; then
  curl -fsSLo $CONMON_DL https://github.com/containers/conmon/releases/download/v2.0.27/conmon.arm64
fi
chmod +x $CONMON_DL
mv /usr/libexec/podman/conmon /usr/libexec/podman/conmon.old

ln -s $CONMON_DL /usr/libexec/podman/conmon

if [ ! -f $PODMAN_DL ]; then
  curl -fsSLo $PODMAN_DL https://raw.githubusercontent.com/boostchicken/udm-utilities/master/podman-update/bin/podman
fi
chmod +x $PODMAN_DL
# mv /usr/bin/podman /usr/bin/podman.old
#ln -s $PODMAN_DL /usr/bin/podman

if [ ! -f $SECCOMP ]; then
  mkdir -p /usr/share/container/
  curl -fsSLo /usr/share/container/seccomp.json https://raw.githubusercontent.com/boostchicken/udm-utilities/master/podman-update/bin/seccomp.json
fi

/usr/bin/podman system service --time=0 tcp:0.0.0.0:2375 &