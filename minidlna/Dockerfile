ARG ALPINE_VERSION=latest

FROM alpine:$ALPINE_VERSION

LABEL maintainer="Vinícius Letério <viniciusleterio@gmail.com>"

# Install samba
RUN file=/etc/minidlna.conf && \
    mkdir -p /minidlna/cache && \
    apk --no-cache --no-progress upgrade && \
    apk --no-cache --no-progress add bash shadow tini tzdata su-exec curl minidlna && \
    echo "port=8200"                    > $file && \
    echo "db_dir=/minidlna/cache/"      >> $file && \
    echo "log_dir=/minidlna/"           >> $file && \
    echo "album_art_names=Cover.jpg/\cover.jpg/\
AlbumArtSmall.jpg/albumartsmall.jpg/AlbumArt.jpg/\
albumart.jpg/Album.jpg/album.jpg/Folder.jpg/folder.jpg/\
Thumb.jpg/thumb.jpg"                    >> $file && \
    echo ""                             >> $file && \
    rm -rf /tmp/*

COPY minidlna.sh /usr/bin/

VOLUME [ "/data" ]

HEALTHCHECK \
    --interval=60s \
    --timeout=15s \
        CMD curl --silent --fail localhost:8200 || exit 1

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/minidlna.sh"]