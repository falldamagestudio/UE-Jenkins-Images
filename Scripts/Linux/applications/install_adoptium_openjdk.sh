#!/bin/bash

function install_adoptium_openjdk () {

    local DOWNLOAD_URL="https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.12%2B7/OpenJDK11U-jdk_x64_linux_hotspot_11.0.12_7.tar.gz"

    local ARCHIVE_FILE=~/adoptium_openjdk.tar.gz
    local INSTALL_ROOT_DIR=~

    wget --progress=dot:giga -O "${ARCHIVE_FILE}" "$DOWNLOAD_URL" || return

    tar --directory "${INSTALL_ROOT_DIR}" -xzf "${ARCHIVE_FILE}" || return

    local JDK_ROOT_DIR
    JDK_ROOT_DIR=$(realpath "$(find "${INSTALL_ROOT_DIR}" -maxdepth 1 -name "jdk-*" -type d)") || return
    local JDK_BIN_DIR="${JDK_ROOT_DIR}/bin"

    export PATH=${JDK_BIN_DIR}:${PATH}

    echo "export PATH=\"${JDK_BIN_DIR}:${PATH}\"" >> ~/.profile || return

    rm -r "${ARCHIVE_FILE}"
}