#!/bin/bash

function install_service () {

    SYSTEMD_UNIT_FILE=$1

    sudo cp "${SYSTEMD_UNIT_FILE}" /etc/systemd/system
}