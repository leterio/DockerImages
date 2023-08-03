FROM alpine:latest

LABEL maintainer="Vinícius Letério <viniciusleterio@gmail.com>"

ARG ALPINE_PACKAGE=minidlna
ARG ALPINE_PACKAGE_VER=

RUN file=/etc/minidlna.conf && \
    mkdir -p /minidlna/cache && \
    apk --no-cache --no-progress upgrade && \
    apk --no-cache --no-progress add bash shadow tini tzdata su-exec curl ${ALPINE_PACKAGE}${ALPINE_PACKAGE_VER:+=${ALPINE_PACKAGE_VER}} && \
    echo "port=8200"               >  $file && \
    echo "db_dir=/minidlna/cache/" >> $file && \
    echo "log_dir=/minidlna/"      >> $file && \
    echo "album_art_names=Cover.jpg/\cover.jpg/AlbumArtSmall.jpg/albumartsmall.jpg/AlbumArt.jpg/albumart.jpg/Album.jpg/album.jpg/Folder.jpg/folder.jpg/Thumb.jpg/thumb.jpg" >> $file && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

COPY --chown=root:root --chmod=0755 root/minidlna.sh /

VOLUME [ "/data" ]

HEALTHCHECK \
    --interval=60s \
    --timeout=15s \
    CMD curl --silent --fail 127.0.0.1:8200 || exit 1

ENTRYPOINT ["/sbin/tini", "--", "/minidlna.sh"]