#!/bin/bash
# Get DataDir location
case "$(ubnt-device-info firmware || true)" in
1*)
    DATA_DIR="/mnt/data"
    ;;
2* | 3* | 4*)
    DATA_DIR="/data"
    ;;
*)
    echo "ERROR: No persistent storage found." 1>&2
    exit 1
    ;;
esac

# Check if the directory exists
if [ ! -d "${DATA_DIR}/scripts" ]; then
  # If it does not exist, create the directory
  mkdir -p "${DATA_DIR}/scripts"
  echo "Directory '${DATA_DIR}/scripts' created."
else
  # If it already exists, print a message
  echo "Directory '${DATA_DIR}/scripts' already exists. Moving on."
fi
mkdir -p ${DATA_DIR}/.cache

PODMAN_VERSION=3.3.0
RUNC_VERSION=1.0.2
CONMON_VERSION=2.0.29
PODMAN_DL=${DATA_DIR}/.cache/podman-$PODMAN_VERSION
RUNC_DL=${DATA_DIR}/.cache/runc-$RUNC_VERSION
CONMON_DL=${DATA_DIR}/.cache/conmon-$CONMON_VERSION
SECCOMP=/usr/share/containers/seccomp.json

while [ ! -f $CONMON_DL ]; do
  curl -fsSLo $CONMON_DL https://github.com/unifi-utilities/unifios-utilities/blob/main/podman-update/bin/conmon-$CONMON_VERSION?raw=true
  sleep 1
done
chmod +x $CONMON_DL
if [ ! -f /usr/libexec/podman/conmon.old ]; then
  mv /usr/libexec/podman/conmon /usr/libexec/podman/conmon.old
fi
ln -s $CONMON_DL /usr/libexec/podman/conmon

if [ ! -f $PODMAN_DL ]; then
  curl -fsSLo $PODMAN_DL https://github.com/unifi-utilities/unifios-utilities/blob/main/podman-update/bin/podman-$PODMAN_VERSION?raw=true
fi
chmod +x $PODMAN_DL
if [ ! -f /usr/bin/podman.old ]; then
  mv /usr/bin/podman /usr/bin/podman.old
fi
ln -s $PODMAN_DL /usr/bin/podman

if [ ! -f $RUNC_DL ]; then
  curl -fsSLo $RUNC_DL https://github.com/unifi-utilities/unifios-utilities/blob/main/podman-update/bin/runc-$RUNC_VERSION?raw=true
fi
chmod +x $RUNC_DL
if [ ! -f /usr/bin/runc.old ]; then
  mv /usr/bin/runc /usr/bin/runc.old
fi
ln -s $RUNC_DL /usr/bin/runc

if [ ! -f $SECCOMP ]; then
  mkdir -p /usr/share/containers/
  curl -fsSLo $SECCOMP https://github.com/unifi-utilities/unifios-utilities/blob/main/podman-update/bin/seccomp.json?raw=true
fi
sed -i 's/driver = ""/driver = "overlay"/' /etc/containers/storage.conf
sed -i 's/ostree_repo = ""/#ostree_repo = ""/' /etc/containers/storage.conf
# Comment out if you don't want to enable docker-compose or remote docker admin
/usr/bin/podman system service --time=0 tcp:0.0.0.0:2375 &
