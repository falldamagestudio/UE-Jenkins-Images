#!/bin/bash

function buildstep_create_agent_host_folders () {

    JENKINS_AGENT_FOLDER=${HOME}/agent
    JENKINS_REMOTING_FOLDER=${HOME}/agent/remoting
    JENKINS_WORKSPACE_FOLDER=${HOME}/workspace

    echo "Creating folders for Jenkins..."

    mkdir -p "${JENKINS_AGENT_FOLDER}"

    # The Swarm agent requires that the remoting folder exists
    mkdir -p "${JENKINS_REMOTING_FOLDER}"

    mkdir -p "${JENKINS_WORKSPACE_FOLDER}"
}