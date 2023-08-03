#!/usr/bin/env bash

# Author:    Vinícius Letério <viniciusleterio@gmail.com>
# Objective: Configure the builder for this image
# Version:   1.0

latestVersionFound=

# Gets the latest LTS ubuntu codename
function retriveLatestVersionNumber() {
    log-trace "Retriving latest Ubuntu LTS codename ..."

    local commandResult=$(curl -s https://changelogs.ubuntu.com/meta-release-lts | grep "Dist: " | tail -n1 | sed "s#Dist\: ##g")
    local commandReturn=$?
    log-trace "commandResult=$commandResult"

    if [[ $commandReturn -ne 0 ]]; then
        log-error "Failed to retrive ${PIP_PACKAGE_NAME} latest version number!"
        return 1
    elif [[ "$commandResult" == "" ]]; then
        log-error "The version returned is empty!"
        return 1
    elif [[ "$(wc -l <<<$commandResult)" -ne 1 ]]; then
        log-error "More than one line has returned. Version number is inconclusive!"
        return 1
    fi

    latestVersionFound="$commandResult"
}

retriveLatestVersionNumber || return 1
log-trace "latestVersionFound=$latestVersionFound"

export TAG_CUSTOMS="$latestVersionFound,$latestVersionFound-$(date +%Y-%m-%d)"
log-trace "TAG_CUSTOMS=$TAG_CUSTOMS"

export BUILD_ARGUMENTS="UBUNTU_IMAGE_VERSION=${latestVersionFound}"
log-trace "BUILD_ARGUMENTS=$BUILD_ARGUMENTS"
