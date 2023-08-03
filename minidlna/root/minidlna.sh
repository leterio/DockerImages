#!/usr/bin/env bash
#===============================================================================
#          FILE: minidlna.sh
#
#         USAGE: ./minidlna.sh
#
#   DESCRIPTION: Entrypoint for minidlna docker container
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Vinícius Letério (viniciusleterio@gmail.com)
#  ORGANIZATION:
#       CREATED: 06/04/2020 (dd/MM/yyyy)
#      REVISION: 1.0
#===============================================================================

set -o nounset

# Script variables
APP_USERNAME="minidlna"
APP_GROUPNAME="minidlna"
APP_NAME="MiniDNLA"
APP_CONFIG_FILE="/etc/minidlna.conf"
APP_PID="/minidlna/minidlna.pid"

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
        log "$message"
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

### setuseruid: set user UID
# Arguments:
#   username) to change uid
#   uid) to set
# Return: UID changed for user if exists
setuseruid() {
    local username="$1" \
          uid="$2"
    grep -q "^$username:" /etc/passwd && {
        log "Setting user \"$username\" UID to \"$uid\""
        usermod \
            --non-unique \
            --uid "$uid" \
            "$username" 2>&1 > /dev/null
    } || {
        log "User \"$username\" not found"
    }
}

### setuseruid: set user GID
# Arguments:
#   username) to change gid
#   gid) to set
# Return: GID changed for user if exists
setusergid() {
    local groupname="$1" \
          gid="$2"
    grep -q "^$groupname:" /etc/group && {
        log "Setting group \"$groupname\" GID to \"$gid\""
        groupmod \
            --non-unique \
            --gid "$gid" \
            "$groupname" 2>&1 > /dev/null
    } || {
        log "Group \"$groupname\" not found"
    }
}

### group: add a group
# Arguments:
#   groupname) for group
#   gid) for group
# Return: group added to container
group() {
    local \
        groupname="$1" \
        gid=$2
    grep -q "^$groupname:" /etc/group && {
        log "Group \"$groupname\" already exists"
    } || {
        log "Creating group: $groupname / $gid"
        groupadd \
            --system \
            --non-unique \
            --gid $gid \
            "$groupname" > /dev/null
        killonfail "Group \"$groupname\" not created" $?
    }
    log "Adding \"$APP_USERNAME\" to group \"$groupname\""
    usermod -aG $groupname $APP_USERNAME > /dev/null
    killonfail "\"$APP_USERNAME\" not added to \"$groupname\"" $?
}

### option: set a config option in a section
# Arguments:
#   section) section of config file
#   option) raw option
# Return: line added to config (replaces existing line with same key)
option() {
    local key="$(sed 's| *=.*||' <<< $1)" \
          value="$(sed 's|[^=]*= *||' <<< $1)" \
          multiple=${2:-"no"}
    log "Setting key \"$key\""
    
    [[ $multiple == "no" ]] && {
        if grep -qE "^$key\ *=" "$APP_CONFIG_FILE"; then
            sed -i '/^#*'"$key"'\ *\=/d' "$APP_CONFIG_FILE"
        fi
    }

    echo "$key=$value" >> "$APP_CONFIG_FILE"
}

### mfriendlyname: Set the option friendly_name
# Arguments:
#   friendlyname: to set
# Return: Config defined
mfriendlyname() {
    local friendlyname=$1
    option "friendly_name=$friendlyname"
}

### minotify: Set the option inotify to yes
# Arguments:
# Return: Config defined
minotify() {
    option "inotify=yes"
}

### mfriendlyname: Set the option media_dir (could be multiple times)
# Arguments:
#   mediadir: to set
# Return: Config defined
mmediadir() {
    local mediadir="$1"
    option "media_dir=$mediadir" yes
}

### usage: Help
# Arguments:
#   none)
# Return: Help text
usage() {
    local RC="${1:-0}"
    echo "
Usage: ${0##*/} [-opt]
Options (fields in '[]' are optional, '<>' are required):
ENV                         OPTION  DESCRIPTION
                            -h      This help
MINIDLNA_UID                -U \"<UID>\"
                                    Set the $APP_USERNAME user UID
MINIDLNA_GID                -G \"<GID>\"
                                    Set the $APP_GROUPNAME user GID
GROUP[0-9]*                 -g \"<groupname;GID>\"
                                    Add a group and include the $APP_USERNAME user
                                    <groupname> for group
                                    <GID> for group
                                    NOTE: Useful when using multiples directories 
                                          with multiples permissions by group
OPTION[0-9]*                -O \"<parameter=value>\"
                                    Set an option to $APP_NAME config file
MINIDLNA_FRIENDLY_NAME      -f \"<friendlyname>\"
                                    Set the friendly name of $APP_NAME
MINIDLNA_INOTIFY            -i      Enable to $APP_NAME monitore files under media_dir
MINIDLNA_MEDIA_DIR[0-9]*    -m \"<mediadir>\"
                                    Set $APP_NAME media dir
" >&2
    exit $RC
}

while getopts ":hU:G:g:O:f:im:" opt; do
    case "$opt" in
        h) usage ;;
        U) eval setuseruid $APP_USERNAME $(sed 's/[^0-9]*//g' <<< $OPTARG) ;;
        G) eval setusergid $APP_GROUPNAME $(sed 's/[^0-9]*//g' <<< $OPTARG) ;;
        g) eval group $(sed 's/^/"/; s/$/"/; s/;/" "/g' <<< $OPTARG) ;;
        O) eval option $(sed 's/^/"/; s/$/"/; s/;/" "/g' <<< $OPTARG) ;;
        f) eval mfriendlyname "$OPTARG" ;;
        i) eval minotify ;;
        m) eval mmediadir "$OPTARG" ;;
        "?") log "Unknown option: -$OPTARG"; usage 1 ;;
        ":") log "No argument value for option: -$OPTARG"; usage 2 ;;
    esac
done
shift $(( OPTIND - 1 ))

[[ "${MINIDLNA_UID:-""}" ]] && eval setuseruid $APP_USERNAME $(sed 's/[^0-9]*//g' <<< $MINIDLNA_UID)

[[ "${MINIDLNA_GID:-""}" ]] && eval setusergid $APP_USERNAME $(sed 's/[^0-9]*//g' <<< $MINIDLNA_GID)

while read i; do
    eval group $(sed 's/^/"/; s/$/"/; s/;/" "/g' <<< $i)
done < <(env | awk '/^GROUP[0-9=_]/ {sub (/^[^=]*=/, "", $0); print}')

while read i; do
    eval option $(sed 's/^/"/; s/$/"/; s/;/" "/g' <<< $i)
done < <(env | awk '/^OPTION[0-9=_]/ {sub (/^[^=]*=/, "", $0); print}')

[[ "${MINIDLNA_FRIENDLYNAME:-""}" ]] && eval mfriendlyname "$MINIDLNA_FRIENDLYNAME"

[[ "${MINIDLNA_INOTIFY:-""}" ]] && eval minotify

while read i; do
    eval mmediadir $i
done < <(env | awk '/^MINIDLNA_MEDIA_DIR[0-9=_]/ {sub (/^[^=]*=/, "", $0); print}')

if ps -ef | egrep -v grep | grep -q minidlnad; then
    log "Service already running, please restart container to apply changes"
else
    log "Updating image ..."
    apk upgrade

    log "Launching $APP_NAME"
    chown -R "minidlna:minidlna" /minidlna
    exec su-exec minidlna /usr/sbin/minidlnad -P "$APP_PID" -S
fi
