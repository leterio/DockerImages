#!/usr/bin/env /bin/sh

EXPECTED_JAR="/minecraft/server.jar"
UID=${UID:-1000}
GID=${GID:-1000}

if [[ ! -f "$EXPECTED_JAR" ]]; then
    echo "Missing $EXPECTED_JAR"
    echo "Put the jar file in the volume with the name \"server.jar\""
    return;
fi

echo "Setting UID(${UID}) and GID(${GID})"
usermod -o -u $UID minecraft > /dev/null
groupmod -o -g $GID minecraft > /dev/null

echo "Fixing permissions"
chown -R minecraft:minecraft /minecraft > /dev/null
find /minecraft -type d -exec chmod 0750 {} \; > /dev/null
find /minecraft -type f -exec chmod 0640 {} \; > /dev/null

echo "Launching Minecraft Server"
exec su-exec minecraft /bin/sh -c "cd /minecraft; java ${JAVA_ARGS} -jar \"${EXPECTED_JAR}\" nogui"