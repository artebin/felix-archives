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

configure_keyboard(){
	printf "Configuring keyboard...\n"
	
	if [[ ! -f /etc/default/keyboard ]]; then
		printf "Cannot find /etc/default/keyboard\n"
		exit 1
	fi
	
	backup_file copy /etc/default/keyboard
	
	printf "XKBMODEL=\"${XKBMODEL}\"\n"
	add_or_update_line_based_on_prefix "XKBMODEL=" "XKBMODEL=\"${XKBMODEL}\"" /etc/default/keyboard
	
	printf "XKBLAYOUT=\"${XKBLAYOUT}\"\n"
	add_or_update_line_based_on_prefix "XKBLAYOUT=" "XKBLAYOUT=\"${XKBLAYOUT}\"" /etc/default/keyboard
	
	printf "XKBVARIANT=\"${XKBVARIANT}\"\n"
	add_or_update_line_based_on_prefix "XKBVARIANT=" "XKBVARIANT=\"${XKBVARIANT}\"" /etc/default/keyboard
	
	printf "XKBOPTIONS=\"${XKBOPTIONS}\"\n"
	add_or_update_line_based_on_prefix "XKBOPTIONS=" "XKBOPTIONS=\"${XKBOPTIONS}\"" /etc/default/keyboard
	
	printf "\n"
}

cd "${RECIPE_DIRECTORY}"
configure_keyboard 2>&1 | tee -a "${RECIPE_LOG_FILE}"
EXIT_CODE="${PIPESTATUS[0]}"
if [ "${EXIT_CODE}" -ne 0 ]; then
	exit "${EXIT_CODE}"
fi
