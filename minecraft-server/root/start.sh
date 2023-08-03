#!/usr/bin/env /bin/sh

EXPECTED_JAR="/minecraft/server.jar"
EXPECTED_RUN="/minecraft/run.sh"

UID=${UID:-1000}
GID=${GID:-1000}

if [[ ! -f "$EXPECTED_JAR" ]] && [[ ! -f "$EXPECTED_RUN" ]]; then
    echo "Missing $EXPECTED_JAR OR $EXPECTED_RUN"
    exit 1;
fi

echo "Setting UID(${UID}) and GID(${GID})"
usermod -o -u $UID minecraft > /dev/null
groupmod -o -g $GID minecraft > /dev/null

echo "Fixing permissions"
chown -R minecraft:minecraft /minecraft > /dev/null
find /minecraft -type d -exec chmod 0750 {} \; > /dev/null
find /minecraft -type f -exec chmod 0640 {} \; > /dev/null

if [[ ! -z $MINECRAFT_EULA ]]; then
    echo "Accepting EULA ..."
    echo "eula=true" > /minecraft/eula.txt
fi

echo "Launching Minecraft Server"
if [[ -f "$EXPECTED_RUN" ]]; then
    chmod +x $EXPECTED_RUN
    echo "Invoking .sh"
    exec su-exec minecraft /bin/sh -c "cd /minecraft; $EXPECTED_RUN"
else
    echo "Invoking .jar"
    exec su-exec minecraft /bin/sh -c "cd /minecraft; java ${JAVA_ARGS} -jar \"${EXPECTED_JAR}\" nogui"
fi
