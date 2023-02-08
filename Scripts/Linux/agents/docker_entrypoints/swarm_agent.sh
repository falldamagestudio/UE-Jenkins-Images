#!/bin/bash

# Expected environment variables:
# JENKINS_URL
# AGENT_USERNAME
# AGENT_API_TOKEN
# AGENT_NAME
# LABELS

#. "${BASH_SOURCE%/*}/../../system_configuration/get_gce_settings.sh"
. "${BASH_SOURCE%/*}/../run/run_swarm_agent.sh"

echo "Swarm Agent starting..."

JENKINS_AGENT_FOLDER=${HOME}/agent
JENKINS_FSROOT_FOLDER=${HOME}        # Per-job workspaces will be created under ${JENKINS_WORKSPACE_FOLDER}/workspace/
AGENT_JAR_LOCATION=/jenkins_agent/swarm-agent.jar
#AGENT_NAME=$(hostname)

#echo "Waiting for required settings to be available in Secrets Manager..."
#
##shellcheck disable=SC2034 # shellcheck doesn't understand that KEYS is being passed by reference to get_gce_settings
#KEYS=("swarm-agent-username" "swarm-agent-api-token")
##shellcheck disable=SC2034 # shellcheck doesn't understand that SOURCES is being passed by reference to get_gce_settings
#SOURCES=("secret" "secret")
##shellcheck disable=SC2034 # shellcheck doesn't understand that BINARY is being passed by reference to get_gce_settings
#BINARY=("false" "false")
#RESULT=()
#get_gce_settings KEYS SOURCES BINARY RESULT "true" "true" || exit
#AGENT_USERNAME=${RESULT[0]}
#AGENT_API_TOKEN=${RESULT[1]}
#JENKINS_URL=${RESULT[0]}
#LABELS=${RESULT[3]}

echo "Running Jenkins Swarm Agent..."

run_swarm_agent "${JENKINS_AGENT_FOLDER}" "${JENKINS_FSROOT_FOLDER}" "${AGENT_JAR_LOCATION}" "${JENKINS_URL}" "${AGENT_USERNAME}" "${AGENT_API_TOKEN}" "${LABELS}" "${AGENT_NAME}" || exit

echo "Swarm Agent has shut down."
