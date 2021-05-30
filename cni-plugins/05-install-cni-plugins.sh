#!/bin/sh

## Set the version of cni plugin to use
CNI_PLUGIN_VER=latest
CNI_CACHE="/mnt/data/.cache/cni-plugins"
CNI_CHECKSUM="sha256"
# Maximum number of loops to attempt to download the plugin if required - setting a 0 or negative value will reinstalled the currently installed version (if in cache)
MAX_TRIES=3

mkdir -p "${CNI_CACHE}"
# The script will attempt to use the nominated version first, and falls back to latest version if that fails
if [ "$#" -eq 0 ]; then
  set ${CNI_PLUGIN_VER}
fi
# This function checks a valid checksum has been selected
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
# Test a fike against it's checksum - 1 is the checksum type, 2 is the file to test and 3 is the checksum file
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

# Install function
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
# Download function
download()
{
  # To stop infinite recursion
  if [ ${MAX_TRIES} -lt 1 ]; then
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
