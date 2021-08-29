#!/bin/bash

function buildstep_create_agent_host_folders () {

    JENKINS_AGENT_FOLDER=${HOME}/agent
    JENKINS_WORKSPACE_FOLDER=${HOME}/workspace

    echo "Creating folders for Jenkins..."

    mkdir -p "${JENKINS_AGENT_FOLDER}"
    mkdir -p "${JENKINS_WORKSPACE_FOLDER}"
}