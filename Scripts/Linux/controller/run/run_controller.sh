#!/bin/bash

function run_controller () {

    # The default logger writes all log messages like this to stderr:
    #
    # Example log output:
    # 2023-03-27 04:14:57.595+0000 [id=1]    INFO    winstone.Logger#logInternal: Beginning extraction from war file
    # 2023-03-27 04:14:57.767+0000 [id=1]    WARNING o.e.j.s.handler.ContextHandler#setContextPath: Empty contextPath
    # 2023-03-27 04:14:57.949+0000 [id=1]    INFO    org.eclipse.jetty.server.Server#doStart: jetty-10.0.12; built: 2022-09-14T01:54:40.076Z; git: 408d0139887e27a57b54ed52e2d92a36731a7e88; jvm 11.0.18+10

    /usr/local/bin/jenkins.sh 2>&1
}