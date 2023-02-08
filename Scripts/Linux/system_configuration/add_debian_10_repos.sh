#!/bin/bash

function add_debian_10_repos () {

    # In order to install Plastic SCM client on debian 11 we need to add debian 10 repositories using workaround
    # provided here https://plasticscmsupport.zendesk.com/hc/en-us/articles/360013103159-How-to-Install-Plastic-GUI-in-Ubuntu-19-10-and-later-
    { echo deb http://deb.debian.org/debian/ buster main || return; } | { tee /etc/apt/sources.list.d/buster-oldlibs.list || return; }
}