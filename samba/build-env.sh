#!/usr/bin/env bash

# Author:    Vinícius Letério <viniciusleterio@gmail.com>
# Objective: Retrives the last version of a alpine package and uses it as tag for publishing the image
# Version:   1.0

ALPINE_PACKAGE="samba"

latestVersionFound=
function retriveLatestVersionNumber() {
    log-trace "Retriving latest version of alpine package \"$ALPINE_PACKAGE\" ..."

    local commandResult=$(docker run --rm --entrypoint sh alpine -c "apk update 2>&1 >/dev/null && apk search -x ${ALPINE_PACKAGE} 2>/dev/null" | sed "s#${ALPINE_PACKAGE}\-##g")
    local commandReturn=$?
    log-trace "commandResult=$commandResult"

    if [[ $commandReturn -ne 0 ]]; then
        log-error "Failed to retrive ${ALPINE_PACKAGE} latest version number!"
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

export BUILD_ARGUMENTS="ALPINE_PACKAGE_VER=${latestVersionFound}"
log-trace "BUILD_ARGUMENTS=$BUILD_ARGUMENTS"
