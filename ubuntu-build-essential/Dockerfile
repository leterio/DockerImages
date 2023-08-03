ARG UBUNTU_IMAGE_VERSION

FROM ubuntu:${UBUNTU_IMAGE_VERSION}

RUN cat /etc/os-release && \
    apt-get update && \
    apt-get dist-upgrade --no-install-recommends -y && \
    apt-get install -y build-essential libssl-dev git && \
    apt-get autoremove --purge -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*