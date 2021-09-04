#!/bin/bash

function run_swarm_agent () {

    JENKINS_AGENT_FOLDER=$1
    JENKINS_FSROOT_FOLDER=$2
    AGENT_JAR_LOCATION=$3
    JENKINS_URL=$4
    AGENT_USERNAME=$5
    AGENT_API_TOKEN=$6
    LABELS=$7
    AGENT_NAME=$8

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
}