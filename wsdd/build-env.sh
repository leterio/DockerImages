#!/usr/bin/env bash

# Author:    Vinícius Letério <viniciusleterio@gmail.com>
# Objective: Retrives the last version of wsdd script and retrives it's version number for building and tagging the image.
# Version:   1.0

downloadTempDir="tmp/"
downloadTempFile="wsdd.py"
latestVersionFound=

# Prepare the temp path that will hold our downloaded file
function prepareTempPath() {
    log-trace "Preparing temp path before downloading WSDD ..."
    rm -rf "$downloadTempDir" 2>/dev/null
    mkdir -p "$downloadTempDir" 2>/dev/null || {
        log-error "Failed to create the temp folder for WSDD download!"
        return 1
    }
}

# Downloads the script from GitHub
function downloadScript() {
    log-info "Downloading WSDD script ..."
    curl https://raw.githubusercontent.com/christgau/wsdd/master/src/wsdd.py -o "${downloadTempDir}/${downloadTempFile}" 2>/dev/null || {
        log-error "Failed to retrive the latest version of the WSDD script from GitHub!"
        return 1
    }
    log-trace "WSDD downloaded!"
}

# Retrives the latest version of the script from GitHub
function getVersionNumber() {
    log-trace "Getting the version number of downloaded script ..."

    local parsedVersion=$(grep "WSDD_VERSION: str =" "${downloadTempDir}/${downloadTempFile}" | grep -Poe "(?<=').*(?=')")
    log-trace "parsedVersion=$parsedVersion"

    if [[ $? -ne 0 ]]; then
        log-error "Failed to retrive latest version number!"
        return 1
    elif [[ "$parsedVersion" == "" ]]; then
        log-error "The version returned is empty!"
        return 1
    elif [[ "$(wc -l <<<$parsedVersion)" -ne 1 ]]; then
        log-error "More than one line has returned. Version number is inconclusive!"
        return 1
    fi

    latestVersionFound="$parsedVersion"
    log-trace "latestVersionFound=$latestVersionFound"
}

prepareTempPath &&
    downloadScript &&
    getVersionNumber ||
    return 1

export TAG_CUSTOMS="$latestVersionFound"
log-trace "TAG_CUSTOMS=$TAG_CUSTOMS"
