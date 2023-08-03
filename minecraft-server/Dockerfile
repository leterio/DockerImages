FROM alpine:latest

LABEL maintainer="Vinícius Letério <viniciusleterio@gmail.com>"

RUN apk --no-cache upgrade && \
    apk --no-cache add openjdk17-jre shadow su-exec tini && \
    addgroup -g 1000 minecraft && \
    adduser -s /bin/sh -D -k /dev/null -u 1000 -G minecraft -h /minecraft minecraft && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

COPY --chown=root:root --chmod=0755 root/start.sh /

EXPOSE 25565

VOLUME [ "/minecraft" ]

ENTRYPOINT [ "/sbin/tini", "--", "/start.sh" ]