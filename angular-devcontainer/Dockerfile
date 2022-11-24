FROM node:lts-alpine

LABEL maintainer="Vinícius Letério <viniciusleterio@gmail.com>"

ARG ANGULAR_VER=

RUN apk --no-cache --no-progress upgrade \
    && apk --no-cache --no-progress add \
        mandoc \
        git \
        git-doc \
        bash \
        sudo \
        shadow \
        su-exec \
        curl \
    && deluser --remove-home node \
    && npm install -g npm @angular/cli${ANGULAR_VER} typescript \
    && npm cache clean --force \
    && rm -rf /tmp/*

COPY skel/ /etc/skel/
COPY entrypoint.sh /entrypoint.sh

VOLUME [ "/src" ]

ENTRYPOINT [ "/entrypoint.sh" ]
