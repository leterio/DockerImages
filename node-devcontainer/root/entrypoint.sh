#!/usr/bin/env bash

# Author:    Vinícius Letério <viniciusleterio@gmail.com>
# Objective: Retrives the latest version for a node package
# Version:   1.0

set -o nounset

USER_UID=${USER_UID:-1000}
GROUP_GID=${GROUP_GID:-1000}

SRC_PATH="/src"
DEFAULT_USER_NAME=${DEFAULT_USER_NAME:-"devel"}

### log: Log any message to output
# Arguments:
#   message) to log
# Return: Formatted message on output
log() {
    local message="${1:-""}"
    [[ $message ]] && echo "${0##*/}: $message"
}

### setsrcperm: Change ownership for source path
# Arguments:
#   path) to set ownership
# Return: Ownership changed for path
setsrcowner() {
    local path="$1"
    [[ ! -e "$path" ]] && { log "Path \"${path}\" not exists."; return 1; }
    if [[ -d "$path" ]]; then
        chown -R ${USER_UID}:${GROUP_GID} "${path}"
    else
        chown ${USER_UID}:${GROUP_GID} "${path}"
    fi
}

### usage: Help
# Arguments:
#   none)
# Return: Help text
usage() {
    local RC="${1:-0}"
    echo "
Usage: ${0##*/} [-opt]
ENV         OPTION         DESCRIPTION
            -h             This help
USER_UID    -i \"<UID>\"     Change the ID for user
GROUP_GID   -g \"<UID>\"     Change the ID for group
" >&2
    exit $RC
}

while getopts ":hi:g:" opt; do
    case "$opt" in
        h) usage ;;
        i) USER_UID=$OPTARG ;;
        g) GROUP_GID=$OPTARG ;;
        "?") log "Unknown option: -$OPTARG"; usage 1 ;;
        ":") log "No argument value for option: -$OPTARG"; usage 2 ;;
    esac
done
shift $(( OPTIND - 1 ))

log "Creating group with GID = ${GROUP_GID}"
groupadd --gid ${GROUP_GID} "${DEFAULT_USER_NAME}"

log "Creating user with UID = ${USER_UID}"
useradd --uid ${USER_UID} --gid ${GROUP_GID} -m "${DEFAULT_USER_NAME}"

log "Adding user to sudo bypass"
echo ${DEFAULT_USER_NAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${DEFAULT_USER_NAME}

log "Updating permissions"
setsrcowner "/home/${DEFAULT_USER_NAME}"
setsrcowner "${SRC_PATH}"

if [ "$#" -eq 0 ]; then
    log "Sleeping through the ages"
    sleep infinity
else
    su-exec "${DEFAULT_USER_NAME}" "$@"
fi
