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

configure_avahi_daemon(){
	printf "Configuring avahi-daemon...\n"
	
	AVAHI_DAEMON_CONF_FILE="/etc/avahi/avahi-daemon.conf"
	backup_file copy "${AVAHI_DAEMON_CONF_FILE}"
	update_line_based_on_prefix 'publish-workstation=' 'publish-workstation=yes' "${AVAHI_DAEMON_CONF_FILE}"
	if [[ $? -eq 0 ]]; then
		systemctl restart avahi-daemon
		systemctl status avahi-daemon
	else
		printf "Cannot find key 'publish-workstation' in AVAHI_DAEMON_CONF_FILE[%s]\n" "${AVAHI_DAEMON_CONF_FILE}"
		return 1
	fi
	
	printf "\n"
}

configure_avahi_daemon 2>&1 | tee -a "${RECIPE_LOG_FILE}"
EXIT_CODE="${PIPESTATUS[0]}"
if [[ "${EXIT_CODE}" -ne 0 ]]; then
	exit "${EXIT_CODE}"
fi
