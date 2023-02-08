#!/bin/bash

function install_service () {

    SOURCE_SYSTEMD_UNIT_FILE=$1
    SERVICE_NAME=$2

    cp "${SOURCE_SYSTEMD_UNIT_FILE}" "/etc/systemd/system/${SERVICE_NAME}" || return

    systemctl daemon-reload || return

    systemctl enable "${SERVICE_NAME}" || return
}