#!/bin/bash

echo "Command line:"
echo "$@"

export AGENT_JAR_LOCATION=./swarm-client.jar
export JENKINS_AGENT_FOLDER=./agent
# export JENKINS_URL=$1
# export AGENT_USERNAME=$2
# export AGENT_API_TOKEN=$3
# export LABELS=$4
export JENKINS_FSROOT_FOLDER=.
export AGENT_NAME=$(hostname)
java \
    -jar "${AGENT_JAR_LOCATION}" \
    -workDir "${JENKINS_AGENT_FOLDER}" \
    -master "${JENKINS_URL}" \
    -username "${AGENT_USERNAME}" \
    -password "${AGENT_API_TOKEN}" \
    -mode exclusive \
    -executors 1 \
    -labels "${LABELS}" \
    -webSocket \
    -disableClientsUniqueId \
    -deleteExistingClients \
    -failIfWorkDirIsMissing \
    -fsroot "${JENKINS_FSROOT_FOLDER}" \
    -name "${AGENT_NAME}"
