FROM python:alpine

LABEL maintainer="Vinícius Letério <viniciusleterio@gmail.com>"

COPY --chown=root:root --chmod=0755 tmp/wsdd.py /
COPY --chown=root:root --chmod=0755 root/wsdd.sh /

RUN apk --no-cache upgrade && \
    apk --no-cache add bash tini && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

ENTRYPOINT ["/sbin/tini", "--", "/wsdd.sh"]