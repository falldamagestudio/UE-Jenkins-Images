#!/bin/bash

function install_jenkins_swarm_agent () {

    DOWNLOAD_URL="https://repo.jenkins-ci.org/artifactory/releases/org/jenkins-ci/plugins/swarm-client/3.25/swarm-client-3.25.jar"

    TARGET_FILE="${HOME}/swarm-agent.jar"

    wget --progress=dot:giga -O "$TARGET_FILE" "$DOWNLOAD_URL" 2>&1
}
