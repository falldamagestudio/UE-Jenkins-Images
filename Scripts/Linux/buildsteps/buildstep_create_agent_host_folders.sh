#!/bin/bash

# This function is intended to be run as the user that will run the Jenkins agent

function buildstep_create_agent_host_folders () {

    JENKINS_AGENT_FOLDER=${HOME}/agent
    JENKINS_REMOTING_FOLDER=${HOME}/agent/remoting
    JENKINS_WORKSPACE_FOLDER=${HOME}/workspace

    echo "Creating folders for Jenkins..."

    mkdir -p "${JENKINS_AGENT_FOLDER}" || return

    # The Swarm agent requires that the remoting folder exists
    mkdir -p "${JENKINS_REMOTING_FOLDER}" || return

    mkdir -p "${JENKINS_WORKSPACE_FOLDER}" || return
}