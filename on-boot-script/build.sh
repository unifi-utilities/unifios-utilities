#!/bin/sh

set -ex

WORK_DIR="$(cd "$(dirname "$0")" && echo "${PWD}")"
SOURCE_DIR_DEB="${WORK_DIR}/dpkg-build-files"
SOURCE_DIR_IMAGES="${WORK_DIR}/images"
TARGET_DIR_IMAGES="${SOURCE_DIR_DEB}/host"
TARGET_DIR_DEB="${WORK_DIR}/packages"
CONTAINER_FILE="${WORK_DIR}/Dockerfile"

UDM_HOST="${UDM_HOST:-"127.0.0.1"}"
UDM_SSH_PORT="${UDM_SSH_PORT:-"22"}"
UDM_USERNAME="${UDM_USERNAME:-"root"}"
UDM_DEPLOY_DIR="/mnt/data/unifi-os"
UDM_UNIFI_DEPLOY_DIR="/data"


fatal() {
	echo "ERROR: ${1}" 1>&2
	exit ${2-1}
}


build_in_container() {
	if ! command -v buildah >/dev/null; then
		fatal "buildah not found"
	fi
	if [ ! -f "${CONTAINER_FILE}" ]; then
		fatal "container file ${CONTAINER_FILE} not found"
	fi

	buildah bud --layers --file "${CONTAINER_FILE}" --tag udm-boot-builder "$(dirname "${CONTAINER_FILE}")"
	container=$(buildah from udm-boot-builder)
	buildah run \
		-v "${SOURCE_DIR_IMAGES}:/images:ro" \
		-v "${SOURCE_DIR_DEB}:/source:ro" \
		-v "${TARGET_DIR_DEB}:/target:rw" \
		-v "${TARGET_DIR_IMAGES}:/target_images:rw" \
		-v "${WORK_DIR}/build.sh:/build.sh:ro" \
		"${container}" \
		-- \
		/build.sh build_container
	buildah rm "${container}"
}


build_deb() {
	source_dir=$1
	target_dir=$2
	version="$(dpkg-parsechangelog --show-field version -l "${source_dir}/debian/changelog")"
	name="$(dpkg-parsechangelog --show-field source -l "${source_dir}/debian/changelog")"
	package_name="${name}-${version}"
	build_dir="$(mktemp --tmpdir="/tmp" --directory "${name}.XXXXXXXXXX")"
	build_package_dir="${build_dir}/${package_name}"


	if [ ! -d "${source_dir}" ]; then
		fatal "source dir ${source_dir} not found" 
	fi
	if [ ! -d "${target_dir}" ]; then
		fatal "target dir ${target_dir} not found" 
	fi

	mkdir -p "${build_package_dir}"
	cp -r "${source_dir}"/* "${build_package_dir}"
	(
		cd "${build_package_dir}"
		# we could exclude "source" here to skip building the source,
        	# but lintian warns only in the source build about some stuff
		debuild -us -uc --build=source,all --lintian-opts --profile debian
	)

	find "${build_dir}" -maxdepth 1 -type f -exec mv {} "${target_dir}" \;
	rm -rf "${build_dir}"
}


build_images() {
	source_dir=$1
	target_dir=$2

	if ! command -v buildah >/dev/null; then
		fatal "buildah not found"
	fi
	if ! command -v qemu-aarch64-static >/dev/null; then
		fatal "qemu-aarch64-static not found"
	fi

	if [ ! -d "${source_dir}" ]; then
		fatal "source dir ${source_dir} not found" 
	fi
	if [ ! -d "${target_dir}" ]; then
		fatal "target dir ${target_dir} not found" 
	fi

	(
		cd "${source_dir}"
		export STORAGE_DRIVER=vfs # required to work on extfs (assume especially WSL nested container)
		for image in systemd podman udm-boot; do
			buildah bud --override-arch arm64 --arch arm64 --file "./Dockerfile.${image}" --tag "${image}" .
		done
		buildah push "udm-boot" "oci-archive:${target_dir}/udm-boot_arm64.tar"
	)
}


build_container() {
	build_images "/images" "/target_images"
	build_deb "/source" "/target" 
}


deploy() {
	version="$(dpkg-parsechangelog --show-field version -l "${SOURCE_DIR_DEB}/debian/changelog")"
	name="$(dpkg-parsechangelog --show-field source -l "${SOURCE_DIR_DEB}/debian/changelog")"
	package_name="${name}_${version}_all.deb"
	package_path="${TARGET_DIR_DEB}/${package_name}"
	if [ ! -f "${package_path}" ]; then
		fatal "package ${package_path} not found"
	fi
	scp -P ${UDM_SSH_PORT} -o StrictHostKeyChecking=no "${package_path}" "${UDM_USERNAME}@${UDM_HOST}:${UDM_DEPLOY_DIR}/"
}


install() {
	version="$(dpkg-parsechangelog --show-field version -l "${SOURCE_DIR_DEB}/debian/changelog")"
	name="$(dpkg-parsechangelog --show-field source -l "${SOURCE_DIR_DEB}/debian/changelog")"
	package_name="${name}_${version}_all.deb"
	package_path="${UDM_UNIFI_DEPLOY_DIR}/${package_name}"
	ssh -p ${UDM_SSH_PORT} -o StrictHostKeyChecking=no "${UDM_USERNAME}@${UDM_HOST}" /usr/bin/podman exec unifi-os dpkg -i "${package_path}"
}


if [ $# -eq 0 ]; then
	build_in_container
fi
if [ "${1}" = "build" ]; then
	build_images "${SOURCE_DIR_IMAGES}" "${TARGET_DIR_IMAGES}"
	build_deb "${SOURCE_DIR_DEB}" "${TARGET_DIR_DEB}"
fi
if [ "${1}" = "build_container" ]; then
	build_container
fi
if [ "${1}" = "deploy" ]; then
	deploy
fi
if [ "${1}" = "install" ]; then
	install
fi

