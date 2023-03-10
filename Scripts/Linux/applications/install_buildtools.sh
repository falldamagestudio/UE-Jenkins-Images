#!/bin/bash

function install_buildtools () {

    ${SUDO} apt-get update || return
    ${SUDO} apt-get install -y --no-install-recommends \
        build-essential \
        apt-transport-https \
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

    ${SUDO} apt-get clean || return
    ${SUDO} rm -rf /var/lib/apt/lists/* || return
}

