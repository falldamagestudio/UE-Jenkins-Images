#!/bin/bash

function run_swarm_agent () {

    AGENT_JAR_LOCATION=$1
    JENKINS_URL=$2
    AGENT_USERNAME=$3
    AGENT_API_TOKEN=$4
    LABELS=$5
    AGENT_NAME=$6

    java \
        -jar "${AGENT_JAR_LOCATION}" \
        -master "${JENKINS_URL}" \
        -username "${AGENT_USERNAME}" \
        -password "${AGENT_API_TOKEN}" \
        -executors 1 \
        -labels "${LABELS}" \
        -webSocket \
        -disableClientsUniqueId \
        -name "${AGENT_NAME}"
}