#!/bin/bash

. "${BASH_SOURCE%/*}/../applications/install_google_cloud_ops_agent.sh"

function buildstep_install_google_cloud_ops_agent () {

    install_google_cloud_ops_agent || return
}
