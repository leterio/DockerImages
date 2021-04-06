#!/usr/bin/env bash
#===============================================================================
#          FILE: samba.sh
#
#         USAGE: ./samba.sh
#
#   DESCRIPTION: Entrypoint for samba docker container
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: David Personette (dperson@gmail.com)
# SIMP. VERSION: Vinícius Letério (viniciusleterio@gmail.com)
#  ORGANIZATION:
#       CREATED: 09/28/2014 12:11
#      REVISION: 1.0-simplified
#===============================================================================

set -o nounset

### killonfail: kill this script
# Arguments:
#   message) to print if exitcode not equal 0
#   exitcode) to verify
# Return: Kills this script if exitcode is not equal to 0
killonfail() {
    local \
        message="$1"
        exitcode=$2
    [[ ! $exitcode == 0 ]] && {
        log $message
        exit $exitcode
    }
}

### log: Log any message to output
# Arguments:
#   message) to log
# Return: Formatted message on output
log() {
    local message="${1:-""}"
    [[ $message ]] && echo "${0##*/}: $message"
}

### user: add a user
# Arguments:
#   username) for user
#   password) for user
#   uid) for user
#   usergroupname) for user
#   gid) for user group
# Return: user added to container
user() {
    local \
        username="$1" \
        password="$2" \
        uid="${3:-""}" \
        usergroupname="${4:-""}" \
        gid="${5:-""}"
    [[ "$usergroupname" ]] && {
        group $usergroupname $gid
    }
    grep -q "^$username:" /etc/passwd && {
        log "User \"$username\" already exists"
    } || {
        log "Creating user: $username"
        adduser \
            -D \
            -H \
            -s /sbin/nologin \
            ${usergroupname:+-G $usergroupname} \
            ${uid:+-u $uid} "$username" > /dev/null
        killonfail "User \"$username\" not created" $?
    }
    log "Setting user \"$username\" password on Samba"
    echo -e "$password\n$password" | smbpasswd -s -a "$username" > /dev/null
}

### group: add a group
# Arguments:
#   groupname) for group
#   gid) for group
#   userlist) to add in this group
# Return: group added to container
group() {
    local \
        groupname="$1" \
        gid="${2:-""}" \
        userlist="${3:-""}" \
        user
    grep -q "^$groupname:" /etc/group && {
        log "Group \"$groupname\" already exists"
    } || {
        log "Creating group: $groupname"
        addgroup \
            ${gid:+--gid $gid }\
            "$groupname" > /dev/null
        killonfail "Group \"$groupname\" not created" $?
    }
    [[ "$userlist" ]] && {
        for user in ${userlist//,/ }; do
            log "Adding \"$user\" to group \"$groupname\""
            usermod -aG $groupname $user > /dev/null
            killonfail "\"$user\" not added to \"$groupname\"" $?
        done
    }
}

### share: Add share
# Arguments:
#   sharename) share name
#   path) path to share
#   browseable) 'yes' or 'no'
#   readonly) 'yes' or 'no'
#   guest) 'yes' or 'no'
#   users) list of allowed users
#   comment) description of share
# Return: result
share() {
    local \
        sharename="$1" \
        path="$2" \
        browseable="${3:-""}" \
        readonly="${4:-""}" \
        createmask="${5:-""}" \
        directorymask="${6:-""}" \
        forcegroup="${7:-""}" \
        guest="${8:-""}" \
        users="${9:-""}" \
        comment="${10:-""}" \
        file=/etc/samba/smb.conf
    log "Creating share: $sharename"
    sed -i "/\\[$sharename\\]/,/^\$/d" $file
    echo "[$sharename]" >> $file
    echo "    path = $path" >> $file
    [[ "$browseable" == no ]] &&
        echo "    browseable = no" >> $file # Defaults to 'yes'
    [[ "$readonly" == no ]] &&
        echo "    read only = no" >> $file # Defaults to 'yes'
    [[ "$createmask" ]] &&
        echo "    create mask = $createmask" >> $file
    [[ "$directorymask" ]] &&
        echo "    directory mask = $directorymask" >> $file
    [[ "$forcegroup" ]] &&
        echo "    force group = $forcegroup" >> $file
    [[ "$guest" == yes ]] &&
        echo "    guest ok = yes" >> $file # Defaults to 'no'
    [[ ${users} && ! ${users} == all ]] &&
        echo "    valid users = $(tr ',' ' ' <<< $users)" >> $file
    [[ ${comment} && ! ${comment} =~ none ]] &&
        echo "    comment = $(tr ',' ' ' <<< $comment)" >> $file
    echo "    veto files = /.apdisk/.DS_Store/.TemporaryItems/.Trashes/desktop.ini/ehthumbs.db/Network Trash Folder/Temporary Items/Thumbs.db/" >> $file
    echo "    delete veto files = yes" >> $file
    echo "" >> $file
    [[ -d $path ]] || {
        log "Creating share \"$sharename\" directory"
        mkdir -p $path > /dev/null
        killonfail "Share \"$sharename\" directory not created" $?
    }
}

### option: set a config option in a section
# Arguments:
#   section) section of config file
#   option) raw option
# Return: line added to smb.conf (replaces existing line with same key)
option() {
    local section="$1" \
          key="$(sed 's| *=.*||' <<< $2)" \
          value="$(sed 's|[^=]*= *||' <<< $2)" \
          file=/etc/samba/smb.conf
    log "Setting key \"$key\" on section \"$section\""
    if sed -n '/^\['"$section"'\]/,/^\[/p' $file | grep -qE '^;*\s*'"$key"; then
        sed -i '/^\['"$1"'\]/,/^\[/s|^;*\s*\('"$key"' = \).*|    \1'"$value"'|' "$file"
    else
        sed -i '/\['"$section"'\]/a \    '"$key = $value" "$file"
    fi
}

### workgroup: set the workgroup
# Arguments:
#   workgroup) the name to set
# Return: configure the correct workgroup
workgroup() {
    local workgroup="$1"
    option "global" "workgroup = $workgroup"
}

### serverstring: set the global 'netbios name'
# Arguments:
#   serverstring) to set
# Return: configure the 'server string'
serverstring() {
    local serverstring="$1"
    option "global" "server string = $serverstring"
}

### interfaces: set the interface to bind
# Arguments:
#   interfaces) list to set
# Return: configure the 'netbios name'
interfaces() {
    local interfaces="$1"
    option "global" "interfaces = $(tr ',' ' ' <<< $interfaces)"
    option "global" "bind interfaces only = yes"
}

### usage: Help
# Arguments:
#   none)
# Return: Help text
usage() {
    local RC="${1:-0}"

    echo "Usage: ${0##*/} [-opt] [command]
Options (fields in '[]' are optional, '<>' are required):
ENV           OPTION  DESCRIPTION
              -h      This help
USER[0-9]*    -u \"<username;password>[;UID;usergroupname;GID]\"
                      Add a user
                      required arg: \"<username>;<passwd>\"
                      <username> for user
                      <password> for user
                      [UID] for user
                      [usergroupname] for user
                      [GID] for user group
GROUP[0-9]*   -g \"<groupname[;GID;userlist]\"
                      Add a group and include users
                      required arg: \"<groupname>\"
                      <groupname> for group
                      [GID] for group
                      NOTE: for user list below, usernames are separated by ','
                      [userlist] to insert on group
SHARE[0-9]*   -s \"<sharename;/path>[;browseable;readonly;createmask;directorymask;forcegroup;guest;users;comment]\"
                      Configure a share
                      required arg: \"<sharename>;</path>\"
                      <sharename> is how it's called for clients
                      <path> path to share
                      NOTE: for the default value, just leave blank
                      [browseable] default:'yes' or 'no'
                      [readonly] default:'yes' or 'no'
                      [createmask] default:unset - IE: 0660
                      [directorymask] default:unset - IE: 0770
                      [forcegroup] default:unset or 'group to force'
                      [guest] allowed default:'no' or 'yes'
                      NOTE: for user lists below, usernames are separated by ','
                      [users] allowed default:unset or list of allowed users
                      [comment] default: unset or description of share
OPTION[0-9]*  -O \"<section;parameter>\"
                      Provide a option for smb.conf
                      required arg: \"<section>\" - IE: \"share\"
                      required arg: \"<parameter>\" - IE: \"log level = 2\"
WORKGROUP     -w \"<workgroup>\"
                      Configure the workgroup (domain) samba should use
                      required arg: \"<workgroup>\" for samba
SERVERSTRING  -S \"<serverstring>\"
                      Set the global 'server string'
                      required arg: \"<serverstring>\" for samba
NMBD          -n      Start the 'nmbd' daemon to advertise the shares

The 'command' (if provided and valid) will be run instead of samba" >&2
    exit $RC
}

while getopts ":hu:g:s:O:w:S:N:i:n" opt; do
    case "$opt" in
        h) usage ;;
        u) eval user $(sed 's/^/"/; s/$/"/; s/;/" "/g' <<< $OPTARG) ;;
        g) eval group $(sed 's/^/"/; s/$/"/; s/;/" "/g' <<< $OPTARG) ;;
        s) eval share $(sed 's/^/"/; s/$/"/; s/;/" "/g' <<< $OPTARG) ;;
        O) eval option $(sed 's/^/"/; s/$/"/; s/;/" "/g' <<< $OPTARG) ;;
        w) workgroup "$OPTARG" ;;
        S) serverstring "$OPTARG" ;;
        n) NMBD="true" ;;
        "?") log "Unknown option: -$OPTARG"; usage 1 ;;
        ":") log "No argument value for option: -$OPTARG"; usage 2 ;;
    esac
done
shift $(( OPTIND - 1 ))

while read i; do
    eval user $(sed 's/^/"/; s/$/"/; s/;/" "/g' <<< $i)
done < <(env | awk '/^USER[0-9=_]/ {sub (/^[^=]*=/, "", $0); print}')

while read i; do
    eval group $(sed 's/^/"/; s/$/"/; s/;/" "/g' <<< $i)
done < <(env | awk '/^GROUP[0-9=_]/ {sub (/^[^=]*=/, "", $0); print}')

while read i; do
    eval share $(sed 's/^/"/; s/$/"/; s/;/" "/g' <<< $i)
done < <(env | awk '/^SHARE[0-9=_]/ {sub (/^[^=]*=/, "", $0); print}')

while read i; do
    eval option $(sed 's/^/"/; s/$/"/; s/;/" "/g' <<< $i)
done < <(env | awk '/^OPTION[0-9=_]/ {sub (/^[^=]*=/, "", $0); print}')

[[ "${WORKGROUP:-""}" ]] && workgroup "$WORKGROUP"

[[ "${SERVERSTRING:-""}" ]] && serverstring "$SERVERSTRING"

if [[ $# -ge 1 && -x $(which $1 2>&-) ]]; then
    exec "$@"
elif [[ $# -ge 1 ]]; then
    log "ERROR: command not found: $1"
    exit 13
elif ps -ef | egrep -v grep | grep -q smbd; then
    log "Service already running, please restart container to apply changes"
else
    [[ ${NMBD:-""} ]] && {
        log "Launching NMBD"
        ionice -c 3 nmbd -D
    }
    log "Launching SMBD"
    exec ionice -c 3 smbd -FS --no-process-group </dev/null
fi
