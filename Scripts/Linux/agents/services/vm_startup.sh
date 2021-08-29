#!/bin/bash

. "${BASH_SOURCE%/*}/../../system_configuration/get_gce_settings.sh"
. "${BASH_SOURCE%/*}/../../applications/deploy_plastic_client_config.sh"

echo "VM Startup script starting..."

echo "Fetching Plastic SCM client config from Secrets Manager..."

#shellcheck disable=SC2034 # shellcheck doesn't understand that KEYS is being passed by reference to get_gce_settings
KEYS=("plastic-config-tgz")
#shellcheck disable=SC2034 # shellcheck doesn't understand that SOURCES is being passed by reference to get_gce_settings
SOURCES=("secret")
#shellcheck disable=SC2034 # shellcheck doesn't understand that BINARY is being passed by reference to get_gce_settings
BINARY=("true")
RESULT=()
get_gce_settings KEYS SOURCES BINARY RESULT "false" "true"
PLASTIC_CLIENT_CONFIG_BASE64=${RESULT[0]}

if [ "${PLASTIC_CLIENT_CONFIG_BASE64}" != "" ]; then
    echo "Deploying Plastic SCM client config..."
    deploy_plastic_client_config "${PLASTIC_CLIENT_CONFIG_BASE64}" || exit
fi

echo "VM Startup script done."
