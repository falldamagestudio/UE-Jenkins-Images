#!/bin/bash

function install_adoptium_openjdk () {

    local SCRIPTS_DIR="${BASH_SOURCE%/*}"

    # Install prerequisites
    ${SUDO} apt-get update || return
    ${SUDO} apt-get install -y apt-transport-https ca-certificates jq wget tar --no-install-recommends || return
    ${SUDO} apt-get clean || return
    ${SUDO} rm -rf /var/lib/apt/lists/* || return

    local DOWNLOAD_URL
    DOWNLOAD_URL=$(jq -r ".adoptium_openjdk_download_url" "${SCRIPTS_DIR}/../tools-and-versions.json") || return

    # Temp archive location
    local ARCHIVE_FILE="${HOME}/adoptium_openjdk.tar.gz"

    # JDK will be placed in a folder named ${INSTALL_ROOT_DIR}/jdk-<version>
    local INSTALL_ROOT_DIR=/usr/lib/jvm

    # Download and unpack JDK

    wget --progress=dot:giga -O "${ARCHIVE_FILE}" "${DOWNLOAD_URL}" 2>&1 || return
    ${SUDO} mkdir -p "${INSTALL_ROOT_DIR}" || return
    ${SUDO} tar --directory "${INSTALL_ROOT_DIR}" -xzf "${ARCHIVE_FILE}" || return
    rm -r "${ARCHIVE_FILE}" || return

    # Create symlink for java binary

    local JDK_ROOT_DIR
    JDK_ROOT_DIR=$(realpath "$(find "${INSTALL_ROOT_DIR}" -maxdepth 1 -name "jdk-*" -type d)") || return
    local JDK_BIN_DIR="${JDK_ROOT_DIR}/bin"
    ${SUDO} ln -s "${JDK_BIN_DIR}/java" /usr/bin/java || return
}