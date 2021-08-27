#!/bin/bash

function install_git () {

    apt-get update
    apt-get install -y git --no-install-recommends

    apt-get clean
    rm -rf /var/lib/apt/lists/*
}

