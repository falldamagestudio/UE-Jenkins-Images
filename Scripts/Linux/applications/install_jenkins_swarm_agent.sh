#!/bin/bash

function install_jenkins_swarm_agent () {

    local SCRIPTS_DIR="${BASH_SOURCE%/*}"

    # Install prerequisites
    ${SUDO} apt-get update || return
    ${SUDO} apt-get install -y apt-transport-https ca-certificates jq wget --no-install-recommends || return
    ${SUDO} apt-get clean || return
    ${SUDO} rm -rf /var/lib/apt/lists/* || return

    local DOWNLOAD_URL
    DOWNLOAD_URL=$(jq -r ".swarm_agent_download_url" "${SCRIPTS_DIR}/../tools-and-versions.json") || return

    local JENKINS_AGENT_FOLDER=/jenkins_agent

    mkdir -p ${JENKINS_AGENT_FOLDER} || return
    chmod 755 ${JENKINS_AGENT_FOLDER} || return

    local TARGET_FILE=${JENKINS_AGENT_FOLDER}/swarm-agent.jar

    # Download swarm agent and place into default location
    wget --progress=dot:giga -O "$TARGET_FILE" "$DOWNLOAD_URL" 2>&1 || return
}
