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

install_dex_from_sources(){
	echo "Installing dex from sources ..."
	
	# Install dependencies
	install_package_if_not_installed "python3-sphinx"
	
	# Clone git repository
	cd "${RECIPE_DIRECTORY}"
	git clone https://github.com/jceb/dex
	
	# Patch dex for supporting 'Terminal=(true|false)' property in .desktop files
	# See <https://github.com/jceb/dex/issues/33>
	cd dex
	patch dex < ../fix_terminal_property.patch
	
	# Install
	make install
	
	# Cleaning
	cd "${RECIPE_DIRECTORY}"
	rm -fr dex
	
	echo
}



cd "${RECIPE_DIRECTORY}"
install_dex_from_sources 2>&1 | tee -a "${RECIPE_LOG_FILE}"
EXIT_CODE="${PIPESTATUS[0]}"
if [ "${EXIT_CODE}" -ne 0 ]; then
	exit "${EXIT_CODE}"
fi
