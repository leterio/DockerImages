#!/usr/bin/env bash

# Author:    Vinícius Letério <viniciusleterio@gmail.com>
# Objective: Retrives the last version of NodeJS and uses it as tag for publishing the image
# Version:   1.0

latestVersionFound=
function retriveLatestVersionNumber() {
    log-trace "Retriving latest version of NodeJS ..."

    local commandResult=$(docker run --rm -it node:lts-alpine --version | sed 's#^v##g;s#\r##g')
    local commandReturn=$?
    log-trace "commandResult=$commandResult"

    if [[ $commandReturn -ne 0 ]]; then
        log-error "Failed to retrive ${NODE_PACKAGE_NAME} latest version number!"
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
