#!/bin/sh

## Set the version of cni plugin to use. It will revert to latest if an invalid version is given, and the installer will use the last installed version if that fails.
# Examples of valid version code would be "latest", "v0.9.1" and "v0.9.0". 
CNI_PLUGIN_VER=latest
# location of the CNI Plugin cached tar files
CNI_CACHE="/mnt/data/.cache/cni-plugins"
# location of the conf files to go in the net.d folder of the cni-plugin directory
CNI_NETD="/mnt/data/podman/cni"
# The checksum to use. For CNI Plugin sha1, sha256 and sha512 are available.
CNI_CHECKSUM="sha256"
# Maximum number of loops to attempt to download the plugin if required - setting a 0 or negative value will reinstalled the currently installed version (if in cache)
MAX_TRIES=3

mkdir -p "${CNI_CACHE}" "${CNI_NETD}"
# The script will attempt to use the nominated version first, and falls back to latest version if that fails
if [ "$#" -eq 0 ]; then
  set ${CNI_PLUGIN_VER}
fi
# Insert conf files for podman networks into the net.d folder
populate_netd()
{
  for file in "${CNI_NETD}"/*.conflist
  do
    if [ -f "$file" ]; then
        ln -fs "$file" "/etc/cni/net.d/$(basename "$file")"
    fi
  done
}
# This function checks a valid checksum has been selected. It requires the checksum is given as the first argument
checksum_check()
{
  if [ "$#" -eq 0 ]; then
    echo "no arguement given"
    return 2
  fi
  case $1 in
    "sha1" | "sha256" | "sha512")
      return 0;
      ;;
     *)
      echo "Incorrect checksum selection"
      return 1;
      ;;
   esac
}
# Test a file against it's checksum - 1 is the checksum type, 2 is the file to test and 3 is the checksum file
checksum_test()
{
  if [ ! -f ${2} ] || [ ! -f ${3} ]; then
    echo "file does not exist"
    return 2
  fi
  if ! checksum_check ${1}; then
    echo "An incorrect checksum has been used"
    return 3
  fi
  value1=$(${1}sum ${2} | awk '{print $1}')
  value2=$(cat ${3} | awk '{print $1}')    
  if [ "${value1}" = "${value2}" ]; then
    return 0
  else
    return 1
  fi
}

# Install function - it requires the first argument to be the version to install
install()
{
  if [ "$#" -eq 0 ]; then
    set "installed"
  fi
  if [ -f "${CNI_CACHE}/cni-plugins-linux-arm64-$1.tgz" ]; then
    echo "Pouring ${CNI_CACHE}/cni-plugins-linux-arm64-$1.tgz"
    rm -rf /opt/cni/bin
    mkdir -p /opt/cni/bin
    tar -xzC /opt/cni/bin -f "${CNI_CACHE}/cni-plugins-linux-arm64-$1.tgz"
    # Create a link to installed version as fallback option
    if [ "$1" != "installed" ]; then
      ln -sf "${CNI_CACHE}/${CNI_TAR}" "${CNI_CACHE}/cni-plugins-linux-arm64-installed.tgz"
      ln -sf "${CNI_CACHE}/${CNI_TAR}.${CNI_CHECKSUM}" "${CNI_CACHE}/cni-plugins-linux-arm64-installed.tgz.${CNI_CHECKSUM}"
    fi
    return 0
  fi
  echo "No CNI Plugin available to install"
  return 1
}
# Download function - the first argument is the version to download. It will default to latest if a invalid option is given.
download()
{
  # To stop infinite recursion
  if [ ${MAX_TRIES} -lt 1 ]; then
    # install the last installed version if latest and specified version have both failed.
    install
    return 1
  fi
  # This defaults to latest, in case the specified download doesn't work.
  if [ "$#" -eq 0 ]; then
    set latest
  fi
  # Find the corect parameters
  set "$(basename "$(curl -fsSLo /dev/null -w "%{url_effective}" https://github.com/containernetworking/plugins/releases/$1)")" "$@"
  CNI_TAR="cni-plugins-linux-arm64-$1.tgz"
  URL="https://github.com/containernetworking/plugins/releases/download/$1/${CNI_TAR}"
  # Cache a checksum for the file
  if [ ! -f "${CNI_CACHE}/${CNI_TAR}.${CNI_CHECKSUM}" ]; then
    echo "Downloading ${URL}.${CNI_CHECKSUM}"
    curl -fsSLo "/tmp/${CNI_TAR}.${CNI_CHECKSUM}" "${URL}.${CNI_CHECKSUM}"
    mv "/tmp/${CNI_TAR}.${CNI_CHECKSUM}" "${CNI_CACHE}/${CNI_TAR}.${CNI_CHECKSUM}"
  fi
  # Cache the tar file
  if [ ! -f "${CNI_CACHE}/${CNI_TAR}" ]; then
    echo "Downloading ${URL}"
    curl -fsSLo "/tmp/${CNI_TAR}" "${URL}"
    mv "/tmp/${CNI_TAR}" "${CNI_CACHE}/${CNI_TAR}"
  fi
  # Symbolic link to latest
  if [ "$1" != "$2" ]; then
    ln -sf "${CNI_CACHE}/${CNI_TAR}" "${CNI_CACHE}/cni-plugins-linux-arm64-$2.tgz"
    ln -sf "${CNI_CACHE}/${CNI_TAR}.${CNI_CHECKSUM}" "${CNI_CACHE}/cni-plugins-linux-arm64-$2.tgz.${CNI_CHECKSUM}"
  fi
  # Test integrity of the files
  if ! checksum_test ${CNI_CHECKSUM} ${CNI_CACHE}/${CNI_TAR} ${CNI_CACHE}/${CNI_TAR}.${CNI_CHECKSUM}; then
    echo "Corrupt tar file, deleting tar and checksum"
    rm -f "${CNI_CACHE}/${CNI_TAR}" "${CNI_CACHE}/${CNI_TAR}.${CNI_CHECKSUM}"
    MAX_TRIES=${(MAX_TRIES - 1)}
    # try again on fallback of latest until retries are exhausted
    download
  else
    install $1 $2
    return 0
  fi
}

download
populate_netd
