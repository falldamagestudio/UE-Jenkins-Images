#!/bin/bash

function install_service () {

    SOURCE_SYSTEMD_UNIT_FILE=$1
    TARGET_FILENAME=$2

    sudo cp "${SOURCE_SYSTEMD_UNIT_FILE}" "/etc/systemd/system/${TARGET_FILENAME}"
}