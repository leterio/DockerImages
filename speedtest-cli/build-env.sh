#!/usr/bin/env bash

# Author:    Vinícius Letério <viniciusleterio@gmail.com>
# Objective: Retrives the last version of a pip package and uses it as tag for publishing the image
# Version:   1.0

PIP_PACKAGE_NAME="speedtest-cli"

latestVersionFound=
function retriveLatestVersionNumber() {
    log-trace "Retriving latest version of pip package \"$PIP_PACKAGE_NAME\" ..."

    local commandResult=$(docker run --rm --entrypoint sh python:alpine -c "pip install ${PIP_PACKAGE_NAME} 2>/dev/null && pip show ${PIP_PACKAGE_NAME}" | egrep "^Version: " | sed "s#Version\: ##g")
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

export TAG_CUSTOMS="$latestVersionFound"
log-trace "TAG_CUSTOMS=$TAG_CUSTOMS"

export BUILD_ARGUMENTS="PIP_PACKAGE_VER=${latestVersionFound}"
log-trace "BUILD_ARGUMENTS=$BUILD_ARGUMENTS"
