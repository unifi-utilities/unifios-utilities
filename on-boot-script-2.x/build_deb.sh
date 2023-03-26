#!/bin/bash

set -e

WORK_DIR="$(cd "$(dirname "$0")" && echo "${PWD}")"
TARGET_DIR="${WORK_DIR}/packages"
SOURCE_DIR="${WORK_DIR}/dpkg-build-files"
CONTAINER_FILE="${WORK_DIR}/Dockerfile"
CONTAINER_CONTEXT="${WORK_DIR}"

fatal() {
	echo "ERROR: ${1}" 1>&2
	exit ${2-1}
}

build_in_container=false
build=false
build_container=false
if [ $# -eq 0 ]; then
	build_in_container=true
fi
if [ "${1}" = "build" ]; then
	build=true
fi
if [ "${1}" = "build_container" ]; then
	build_container=true
fi


build_in_container() {
	docker_exec="$(command -v docker || true)"
	podman_exec="$(command -v podman || true)"
	container_exec="${docker_exec:-"${podman_exec}"}"
	container_args=""

	if [ ! -f "${container_exec}" ]; then
		fatal "docker or podman not found"
	fi
	if [ ! -f "${CONTAINER_FILE}" ]; then
		fatal "container file ${CONTAINER_FILE} not found"
	fi

	if [ "${container_exec}" = "${docker_exec}" ]; then
		# docker does not map user, so we run it as user
		container_args="--user "$(id -u):$(id -g)""
	fi
	"${container_exec}" build --file "${CONTAINER_FILE}" --tag udm-boot-deb-builder "${CONTAINER_CONTEXT}"
	"${container_exec}" run -it \
		${container_args} \
		-v "${SOURCE_DIR}:/source:ro" \
		-v "${TARGET_DIR}:/target:rw" \
		-v "${WORK_DIR}/build_deb.sh:/build_deb.sh:ro" \
		--rm \
		udm-boot-deb-builder \
		/build_deb.sh build_container
}


build() {
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

build_container() {
	build "/source" "/target" 
}

if [ $build_in_container = true ]; then
	build_in_container
fi
if [ $build = true ]; then
	build "${SOURCE_DIR}" "${TARGET_DIR}"
fi
if [ $build_container = true ]; then
	build_container
fi

