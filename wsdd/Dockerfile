FROM alpine AS downloader
RUN apk --no-cache --no-progress add curl && \
    curl https://raw.githubusercontent.com/christgau/wsdd/master/src/wsdd.py -o /tmp/wsdd.py
    
FROM python:alpine

LABEL maintainer="Vinícius Letério <viniciusleterio@gmail.com>"

COPY --from=downloader /tmp/wsdd.py /wsdd.py
COPY wsdd.sh /usr/bin/wsdd.sh

RUN apk --no-cache --no-progress upgrade && \
    apk --no-cache --no-progress add bash tini && \
    rm -rf /tmp/*

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/wsdd.sh"]