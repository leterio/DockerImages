ARG ALPINE_VERSION=latest

FROM alpine:$ALPINE_VERSION

LABEL maintainer="Vinícius Letério <viniciusleterio@gmail.com>"

RUN apk --no-cache --no-progress upgrade && \
    apk --no-cache --no-progress add openjdk17-jre shadow su-exec && \
    addgroup -g 1000 minecraft && \
    adduser -s /bin/sh -D -k /dev/null -u 1000 -G minecraft -h /minecraft minecraft && \
    rm -rf /tmp/*

COPY --chmod=0500 start.sh /start.sh

EXPOSE 25565

VOLUME [ "/minecraft" ]

ENTRYPOINT [ "/start.sh" ]