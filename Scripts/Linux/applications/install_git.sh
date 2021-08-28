#!/bin/bash

function install_git () {

    apt-get update || return
    apt-get install -y git --no-install-recommends || return

    apt-get clean || return
    rm -rf /var/lib/apt/lists/*
}

