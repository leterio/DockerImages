FROM alpine:latest

ARG ALPINE_PACKAGE=samba
ARG ALPINE_PACKAGE_VER=

LABEL maintainer="Vinícius Letério <viniciusleterio@gmail.com>"

# Install samba
RUN apk --no-cache --no-progress upgrade && \
    apk --no-cache --no-progress add bash shadow tini tzdata ${ALPINE_PACKAGE}${ALPINE_PACKAGE_VER:+=${ALPINE_PACKAGE_VER}} && \
    mkdir /shares && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

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

COPY --chown=root:root --chmod=0755 root/samba.sh /

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

ENTRYPOINT ["/sbin/tini", "--", "/samba.sh"]
