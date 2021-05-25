#!/bin/sh

mkdir -p /mnt/data/.cache

PODMAN_VERSION=3.2.0-dev
RUNC_VERSION=1.0.0-rc95
CONMON_VERSION=2.0.27
PODMAN_DL=/mnt/data/.cache/podman-$PODMAN_VERSION
RUNC_DL=/mnt/data/.cache/runc-$RUNC_VERSION
CONMON_DL=/mnt/data/.cache/conmon-$CONMON_VERSION
SECCOMP=/usr/share/container/seccomp.json

if [ ! -f CONMON_DL ]; then
  curl -fsSLo $CONMON_DL https://github.com/containers/conmon/releases/download/v$CONMON_VERSION/conmon.arm64
fi
chmod +x $CONMON_DL
if [ ! -f /usr/libexec/podman/conmon.old ]; then
  mv /usr/libexec/podman/conmon /usr/libexec/podman/conmon.old
fi

ln -s $CONMON_DL /usr/libexec/podman/conmon

if [ ! -f $PODMAN_DL ]; then
  curl -fsSLo $PODMAN_DL https://raw.githubusercontent.com/boostchicken/udm-utilities/master/podman-update/bin/podman-$PODMAN_VERSION
fi
chmod +x $PODMAN_DL
if [ ! -f /usr/bin/podman.old ]; then
  mv /usr/bin/podman /usr/bin/podman.old
fi
ln -s $PODMAN_DL /usr/bin/podman

if [ ! -f $RUNC_DL ]; then
  curl -fsSLo $RUNC_DL https://raw.githubusercontent.com/boostchicken/udm-utilities/master/podman-update/bin/runc-$RUNC_VERSION
fi
chmod +x $RUNC_DL
if [ ! -f /usr/bin/runc.old ]; then
  mv /usr/bin/runc /usr/bin/runc.old
fi
ln -s $RUNC_DL /usr/bin/runc

if [ ! -f $SECCOMP ]; then
  mkdir -p /usr/share/container/
  curl -fsSLo /usr/share/container/seccomp.json https://raw.githubusercontent.com/boostchicken/udm-utilities/master/podman-update/bin/seccomp.json
fi
sed -i 's/driver = ""/driver = "overlay"/' /etc/containers/storage.conf
# Comment out if you don't want to enable docker-compose or remote docker admin
/usr/bin/podman system service --time=0 tcp:0.0.0.0:2375 &