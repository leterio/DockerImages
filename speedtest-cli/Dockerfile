FROM python:alpine

LABEL maintainer="Vinícius Letério <viniciusleterio@gmail.com>"

ARG PIP_PACKAGE=speedtest-cli
ARG PIP_PACKAGE_VER=

RUN apk --no-cache upgrade && \
    apk --no-cache add tini && \
    pip list --outdated --format=columns | tail -n +3 | awk '{print $1}' | xargs -n1 pip install -U && \
    pip install ${PIP_PACKAGE}${PIP_PACKAGE_VER:+==${PIP_PACKAGE_VER}} && \
    pip cache purge && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/python", "/usr/local/bin/speedtest-cli"]
