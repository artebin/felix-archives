#!/usr/bin/env bash

RECIPE_DIRECTORY="$(dirname ${BASH_SOURCE}|xargs readlink -f)"
FELIX_SH="$(eval find ./$(printf "{$(echo %{1..10}q,)}" | sed 's/ /\.\.\//g')/ -maxdepth 1 -name felix.sh)"
if [[ ! -f "${FELIX_SH}" ]]; then
	printf "Cannot find felix.sh\n"
	exit 1
fi
FELIX_SH="$(readlink -f "${FELIX_SH}")"
FELIX_ROOT="$(dirname "${FELIX_SH}")"
source "${FELIX_SH}"
initialize_recipe "${RECIPE_DIRECTORY}"

exit_if_not_bash
exit_if_has_not_root_privileges

APT_MIRROR_BASE_PATH="/media/njames/FONDA-EXT4/UbuntuMirror/Bionic"

configure_apt_mirror(){
	echo "Configuring apt-mirror ..."
	if [[ -f /etc/apt/mirror.list ]]; then
		backup_file rename /etc/apt/mirror.list
	fi
	cp "${RECIPE_DIRECTORY}/apt.mirror.list" /etc/apt/mirror.list
	sed -i "s|APT_MIRROR_BASE_PATH|${APT_MIRROR_BASE_PATH}|g" /etc/apt/mirror.list
	
	printf "Once the mirror is complete, start a http server for the repository:\n"
	printf "  - go into APT_MIRROR_BASE_PATH/mirror/archive.ubuntu.com\n"
	printf "  - execute 'python -m SimpleHTTPServer 10001'\n"
	
	echo
}

cd "${RECIPE_DIRECTORY}"
configure_apt_mirror 2>&1 | tee -a "${RECIPE_LOG_FILE}"
EXIT_CODE="${PIPESTATUS[0]}"
if [[ "${EXIT_CODE}" -ne 0 ]]; then
	exit "${EXIT_CODE}"
fi
