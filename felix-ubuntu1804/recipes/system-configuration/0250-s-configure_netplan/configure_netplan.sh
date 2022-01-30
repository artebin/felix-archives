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

configure_netplan(){
	printf "Disabling previous NetPlan configuration ...\n"
	for NETPLAN_YAML_FILE in /etc/netplan/*.yaml; do
		backup_file rename "${NETPLAN_YAML_FILE}"
	done
	
	printf "Configuring NetPlan for using the NetworkManager as renderer...\n"
	cp ./01-netcfg.yaml /etc/netplan/
	netplan generate
	netplan apply
	
	printf "\n"
}

cd "${RECIPE_DIRECTORY}"
configure_netplan 2>&1 | tee -a "${RECIPE_LOG_FILE}"
EXIT_CODE="${PIPESTATUS[0]}"
if [[ "${EXIT_CODE}" -ne 0 ]]; then
	exit "${EXIT_CODE}"
fi
