#!/bin/bash

function install_git () {

    sudo apt-get update || return
    sudo --preserve-env=DEBIAN_FRONTEND apt-get install -y git --no-install-recommends || return

    sudo apt-get clean || return
    sudo rm -rf /var/lib/apt/lists/*
}

