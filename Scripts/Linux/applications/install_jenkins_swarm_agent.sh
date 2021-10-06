#!/bin/bash

function install_jenkins_swarm_agent () {

    # Install prerequisites
    sudo apt-get update || return
    sudo --preserve-env=DEBIAN_FRONTEND apt-get install -y apt-transport-https ca-certificates jq wget --no-install-recommends || return
    sudo apt-get clean || return
    sudo rm -rf /var/lib/apt/lists/* || return

    local DOWNLOAD_URL
    DOWNLOAD_URL=$(jq -r ".swarm_agent_download_url" "${SCRIPTS_DIR}/../tools-and-versions.json") || return

    local JENKINS_AGENT_FOLDER=${HOME}/agent
    local TARGET_FILE=${JENKINS_AGENT_FOLDER}/swarm-agent.jar

    # Download swarm agent and place into default location
    wget --progress=dot:giga -O "$TARGET_FILE" "$DOWNLOAD_URL" 2>&1
}
