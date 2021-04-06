ARG ALPINE_VERSION=latest

FROM alpine:$ALPINE_VERSION

LABEL maintainer="Vinícius Letério <viniciusleterio@gmail.com>"

# Install samba
RUN apk --no-cache --no-progress upgrade && \
    apk --no-cache --no-progress add bash samba shadow tini tzdata && \
    mkdir /shares && \
    rm -rf /tmp/*

# Define Samba config file
RUN file=/etc/samba/smb.conf && \
    echo "[global]"                              >  $file && \
    echo "    log file = /dev/stdout"            >> $file && \
    echo "    smb encrypt = auto"                >> $file && \
    echo "    security = user"                   >> $file && \
    echo "    encrypt passwords = yes"           >> $file && \
    echo "    client ipc max protocol = SMB3"    >> $file && \
    echo "    client ipc min protocol = SMB2_10" >> $file && \
    echo "    client max protocol = SMB3"        >> $file && \
    echo "    client min protocol = SMB2_10"     >> $file && \
    echo "    server max protocol = SMB3"        >> $file && \
    echo "    server min protocol = SMB2_10"     >> $file && \
    echo "    map to guest = bad user"           >> $file && \
    echo "    strict locking = no"               >> $file && \
    echo "    security = user"                   >> $file && \
    echo "    workgroup = WORKGROUP"             >> $file && \
    echo "    follow symlinks = yes"             >> $file && \
    echo ""                                      >> $file

COPY samba.sh /usr/bin/

EXPOSE \
    137/udp \
    138/udp \
    139 \
    445

HEALTHCHECK \
    --interval=60s \
    --timeout=15s \
        CMD smbclient -L \\localhost -U % -m SMB3

VOLUME [ "/shares" ]

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/samba.sh"]
