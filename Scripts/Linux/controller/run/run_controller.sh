#!/bin/bash

function run_controller () {

    # Jenkins core writes all log messages to stderr. It has INFO/WARNING/SEVERE levels within the text lines printed.
    #
    # Example log output:
    # 2023-03-27 04:14:57.595+0000 [id=1]    INFO    winstone.Logger#logInternal: Beginning extraction from war file
    # 2023-03-27 04:14:57.767+0000 [id=1]    WARNING o.e.j.s.handler.ContextHandler#setContextPath: Empty contextPath
    # 2023-03-27 04:14:57.949+0000 [id=1]    INFO    org.eclipse.jetty.server.Server#doStart: jetty-10.0.12; built: 2022-09-14T01:54:40.076Z; git: 408d0139887e27a57b54ed52e2d92a36731a7e88; jvm 11.0.18+10
    #
    # If these log messages are sent as-is to stderr, they result in priority level 3 entries (which show up as errors in GCP's Logs Explorer).
    #
    # To make these useful, we need to inspect the java.util.Logging log level in each message and prepend a Syslog/systemd priority level prefix:
    # - Prefix each line containing 'INFO' with <6>
    # - Prefix each line containing 'WARNING' with <5>
    # - Prefix each line containing 'SEVERE' with <3>
    # - Prefix each line containing neither with <6>
    # Reference: https://docs.oracle.com/javase/7/docs/api/java/util/logging/Level.html
    # Reference: https://en.wikipedia.org/wiki/Syslog#Severity_level
    # Reference: http://0pointer.de/public/systemd-man/sd-daemon.html

    local TAB
    TAB="\t"

    /usr/local/bin/jenkins.sh 2> >(sed -u "/${TAB}INFO${TAB}/ { s/^/<6>/ ; b } ; /${TAB}WARNING${TAB}/ { s/^/<5>/; b } ; /${TAB}SEVERE${TAB}/ { s/^/<3>/; b } ; s/^/<6>/")
}