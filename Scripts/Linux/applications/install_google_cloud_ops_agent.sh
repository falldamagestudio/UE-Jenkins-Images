#!/bin/bash

function install_google_cloud_ops_agent () {

   local SCRIPTS_DIR="${BASH_SOURCE%/*}"

    # Install prerequisites
    apt-get update || return
    apt-get install -y apt-transport-https ca-certificates jq wget tar --no-install-recommends || return
    apt-get clean || return
    rm -rf /var/lib/apt/lists/* || return

    local DOWNLOAD_URL
    DOWNLOAD_URL=$(jq -r ".google_cloud_ops_agent_install_script_url" "${SCRIPTS_DIR}/../tools-and-versions.json") || return

    # Temp script location
    local INSTALL_SCRIPT="${HOME}/add-google-cloud-ops-agent-repo.sh"

    # Download and run installer

    wget -O "${INSTALL_SCRIPT}" "${DOWNLOAD_URL}" 2>&1 || return
    bash "${INSTALL_SCRIPT}" --also-install || return
    rm -r "${INSTALL_SCRIPT}" || return
}
