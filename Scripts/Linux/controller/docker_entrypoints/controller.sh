#!/bin/bash

# Expected environment variables:
# JENKINS_URL
# AGENT_NAME
# LABELS

. "${BASH_SOURCE%/*}/../../system_configuration/get_gce_settings.sh"
. "${BASH_SOURCE%/*}/../run/run_controller.sh"

echo "Controller starting..."

CONTROLLER_FOLDER=${HOME}
PLASTIC_CONFIG_FOLDER=${CONTROLLER_FOLDER}/.plastic4

echo "Fetching Plastic configuration from Secrets manager..."

#shellcheck disable=SC2034 # shellcheck doesn't understand that KEYS is being passed by reference to get_gce_settings
KEYS=("plastic-config-tgz")
#shellcheck disable=SC2034 # shellcheck doesn't understand that SOURCES is being passed by reference to get_gce_settings
SOURCES=("secret")
#shellcheck disable=SC2034 # shellcheck doesn't understand that BINARY is being passed by reference to get_gce_settings
BINARY=("true")
RESULT=()
get_gce_settings KEYS SOURCES BINARY RESULT "true" "true" || exit
PLASTIC_CONFIG_TGZ_BASE64=${RESULT[0]}

echo "Decompressing Plastic config..."

echo -n "${PLASTIC_CONFIG_TGZ_BASE64}" | { base64 --decode || exit; } | tar --directory "${PLASTIC_CONFIG_FOLDER}" -xzvf -

echo "Running controller..."

run_controller || exit

echo "controller has shut down."
