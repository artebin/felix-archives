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

install_pass_1_7_3_from_sources(){
	printf "Installing pass V1.7.3 from sources ...\n"
	
	# Download and unpack sources tarball
	wget -q https://git.zx2c4.com/password-store/snapshot/password-store-1.7.3.tar.xz
	tar xf password-store-1.7.3.tar.xz
	
	# Install
	cd "${RECIPE_DIRECTORY}"
	cd password-store-1.7.3
	make install
	
	# Cleaning
	cd "${RECIPE_DIRECTORY}"
	rm -fr password-store-1.7.3
	rm -fr password-store-1.7.3.tar.xz
	
	printf "\n"
}

install_pass_1_7_3_from_sources 2>&1 | tee -a "${RECIPE_LOG_FILE}"
EXIT_CODE="${PIPESTATUS[0]}"
if [[ "${EXIT_CODE}" -ne 0 ]]; then
	exit "${EXIT_CODE}"
fi
