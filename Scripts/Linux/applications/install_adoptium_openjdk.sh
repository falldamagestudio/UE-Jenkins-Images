#!/bin/bash

function install_adoptium_openjdk () {

    local DOWNLOAD_URL="https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.12%2B7/OpenJDK11U-jdk_x64_linux_hotspot_11.0.12_7.tar.gz"

    # Temp archive location
    local ARCHIVE_FILE="${HOME}/adoptium_openjdk.tar.gz"

    # JDK will be placed in a folder named ${INSTALL_ROOT_DIR}/jdk-<version>
    local INSTALL_ROOT_DIR=/usr/lib/jvm

    # Download and unpack JDK

    wget --progress=dot:giga -O "${ARCHIVE_FILE}" "${DOWNLOAD_URL}" 2>&1 || return
    sudo mkdir -p "${INSTALL_ROOT_DIR}" || return
    sudo tar --directory "${INSTALL_ROOT_DIR}" -xzf "${ARCHIVE_FILE}" || return
    rm -r "${ARCHIVE_FILE}" || return

    # Create symlink for java binary

    local JDK_ROOT_DIR
    JDK_ROOT_DIR=$(realpath "$(find "${INSTALL_ROOT_DIR}" -maxdepth 1 -name "jdk-*" -type d)") || return
    local JDK_BIN_DIR="${JDK_ROOT_DIR}/bin"
    sudo ln -s "${JDK_BIN_DIR}/java" /usr/bin/java || return
}