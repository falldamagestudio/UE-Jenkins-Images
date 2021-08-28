#!/bin/bash

function install_buildtools () {

    apt-get update || return
    apt-get install -y --no-install-recommends \
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

    apt-get clean || return
    rm -rf /var/lib/apt/lists/*
}

