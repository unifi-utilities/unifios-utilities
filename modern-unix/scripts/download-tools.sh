#!/usr/bin/env bash

set -e

SCRIPTS=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

source "${SCRIPTS}/colors.sh"

printf "${YELLOW}%s${NC}\n" "Installing tools..."

target_dir="/data/opt"
temp_dir="$(mktemp -d)"

bat_version=0.22.1
croc_version=9.6.3
duf_version=0.8.1
ncdu_version=2.2.1
lsd_version=0.23.1
xh_version=0.18.0

function download_and_extract() {
  printf "${GREEN}%s${NC}\n" "Downloading $1..."
  filename="$(basename "$1")"
  wget -q "$1" -O "${temp_dir}/package.${filename##*.}"

  printf "${GREEN}%s${NC}" "Extracting... "
  if [[ ${filename##*.} == 'zip' ]]; then
    extract_zip "$2"
  else
    extract_tar "$2"
  fi
}

function extract_zip() {
  unzip -o -j "${temp_dir}/package.zip" -d "${target_dir}" "$1"
  rm -f "${temp_dir}/package.zip"
}

function extract_tar() {
  if [[ $1 == *"/"* ]]; then
    tar xzvf "${temp_dir}/package.gz" --directory="${target_dir}" --strip-components=1 "$1" --no-same-owner
  else
    tar xzvf "${temp_dir}/package.gz" --directory="${target_dir}" "$1" --no-same-owner
  fi

  rm -f "${temp_dir}/package.*"
}

mkdir -p "${target_dir}"

archive_name="bat-v${bat_version}-aarch64-unknown-linux-gnu"
download_and_extract "https://github.com/sharkdp/bat/releases/download/v${bat_version}/bat-v${bat_version}-aarch64-unknown-linux-gnu.tar.gz" "${archive_name}/bat"
download_and_extract "https://github.com/ClementTsang/bottom/releases/latest/download/bottom_aarch64-unknown-linux-musl.tar.gz" btm
download_and_extract "https://github.com/schollz/croc/releases/download/v${croc_version}/croc_${croc_version}_Linux-ARM64.tar.gz" croc
download_and_extract "https://github.com/muesli/duf/releases/download/v${duf_version}/duf_${duf_version}_linux_arm64.tar.gz" duf
download_and_extract "https://github.com/orf/gping/releases/latest/download/gping-aarch64-unknown-linux-musl.tar.gz" gping

download_and_extract "https://dev.yorhel.nl/download/ncdu-${ncdu_version}-linux-aarch64.tar.gz" ncdu

archive_name="lsd-${lsd_version}-aarch64-unknown-linux-musl"
download_and_extract "https://github.com/Peltoche/lsd/releases/download/${lsd_version}/${archive_name}.tar.gz" "${archive_name}/lsd"
archive_name="xh-v${xh_version}-aarch64-unknown-linux-musl"
download_and_extract "https://github.com/ducaale/xh/releases/download/v${xh_version}/xh-v${xh_version}-aarch64-unknown-linux-musl.tar.gz" "${archive_name}/xh"

rm -rf "${temp_dir}"
