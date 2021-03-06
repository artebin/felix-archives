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

disable_automatic_update_and_upgrade(){
	printf "Disable apt-daily.service...\n"
	
	# See <https://askubuntu.com/questions/1057458/how-to-remove-ubuntus-automatic-internet-connection-needs/1057463#1057463>
	
	# apt-daily must not be disabled for the detection of security updates
	#systemctl stop apt-daily.timer
	#systemctl disable apt-daily.timer
	#systemctl disable apt-daily.service
	
	systemctl stop apt-daily-upgrade.timer
	systemctl disable apt-daily-upgrade.timer
	systemctl disable apt-daily-upgrade.service
	
	printf "\n"
	
	printf "Remove unattended-upgrades...\n"
	remove_with_purge_package_if_installed "unattended-upgrades"
	
	printf "\n"
}

disable_automatic_update_and_upgrade 2>&1 | tee -a "${RECIPE_LOG_FILE}"
EXIT_CODE="${PIPESTATUS[0]}"
if [[ "${EXIT_CODE}" -ne 0 ]]; then
	exit "${EXIT_CODE}"
fi
