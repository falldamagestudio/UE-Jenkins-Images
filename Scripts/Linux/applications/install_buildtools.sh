#!/bin/bash

function install_buildtools () {

    sudo apt-get update || return
    sudo apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        git \
        jq \
        mono-runtime \
        python3 \
        python3-dev \
        python3-pip \
        shared-mime-info \
        tzdata \
        unzip \
        xdg-user-dirs \
        zip || return

    sudo apt-get clean || return
    sudo rm -rf /var/lib/apt/lists/*
}

