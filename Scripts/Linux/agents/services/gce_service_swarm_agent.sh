#!/bin/bash

. "${BASH_SOURCE%/*}/../../system_configuration/get_gce_settings.sh"
. "${BASH_SOURCE%/*}/../run/run_swarm_agent.sh"

echo "Swarm Agent starting..."

JENKINS_AGENT_FOLDER=${HOME}/agent
JENKINS_FSROOT_FOLDER=${HOME}        # Per-job workspaces will be created under ${JENKINS_WORKSPACE_FOLDER}/workspace/
AGENT_JAR_LOCATION=${JENKINS_AGENT_FOLDER}/swarm-agent.jar
AGENT_NAME=$(hostname)

echo "Waiting for required settings to be available in Secrets Manager / Instance Metadata..."

#shellcheck disable=SC2034 # shellcheck doesn't understand that KEYS is being passed by reference to get_gce_settings
KEYS=("jenkins-url" "swarm-agent-username" "swarm-agent-api-token" "jenkins-labels")
#shellcheck disable=SC2034 # shellcheck doesn't understand that SOURCES is being passed by reference to get_gce_settings
SOURCES=("secret" "secret" "secret" "instance-metadata")
#shellcheck disable=SC2034 # shellcheck doesn't understand that BINARY is being passed by reference to get_gce_settings
BINARY=("false" "false" "false" "false")
RESULT=()
get_gce_settings KEYS SOURCES BINARY RESULT "true" "true" || exit
JENKINS_URL=${RESULT[0]}
AGENT_USERNAME=${RESULT[1]}
AGENT_API_TOKEN=${RESULT[2]}
LABELS=${RESULT[3]}

echo "Running Jenkins Agent..."

run_swarm_agent "${JENKINS_AGENT_FOLDER}" "${JENKINS_FSROOT_FOLDER}" "${AGENT_JAR_LOCATION}" "${JENKINS_URL}" "${AGENT_USERNAME}" "${AGENT_API_TOKEN}" "${LABELS}" "${AGENT_NAME}" || exit

echo "Jenkins Startup script done."
