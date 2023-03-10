#!/bin/bash

function install_git () {

    ${SUDO} apt-get update || return
    ${SUDO} apt-get install -y git --no-install-recommends || return

    ${SUDO} apt-get clean || return
    ${SUDO} rm -rf /var/lib/apt/lists/* || return
}

