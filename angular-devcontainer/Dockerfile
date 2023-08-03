FROM node:lts-alpine

LABEL maintainer="Vinícius Letério <viniciusleterio@gmail.com>"

ARG NODE_PACKAGE=@angular/cli
ARG NODE_PACKAGE_VER=

RUN apk --no-cache upgrade && \
    apk --no-cache add mandoc git git-doc bash sudo shadow su-exec curl tini && \
    deluser --remove-home node && \
    npm install -g npm ${NODE_PACKAGE}${NODE_PACKAGE_VER:+@${NODE_PACKAGE_VER}} typescript -dd && \
    rm -rf /root/.npm /var/cache/apk/* /tmp/* /var/tmp/*

COPY --chown=root:root --chmod=0644 root/etc /etc
COPY --chown=root:root --chmod=0755 root/entrypoint.sh /

VOLUME [ "/src" ]

ENTRYPOINT [ "/sbin/tini", "--", "/entrypoint.sh" ]
