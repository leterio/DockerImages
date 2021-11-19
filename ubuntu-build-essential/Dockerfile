ARG UBUNTU_IMAGE_VERSION

FROM ubuntu:${UBUNTU_IMAGE_VERSION}

RUN sed 's+http://archive.ubuntu.com/ubuntu/+http://mirror.uepg.br/ubuntu/+g' -i /etc/apt/sources.list && \
    cat /etc/os-release && \
        && apt-get update && \
        && apt-get install -y \
            build-essential \
            libssl-dev \
            git && \
        && sed 's+http://mirror.uepg.br/ubuntu/+http://archive.ubuntu.com/ubuntu/+g' -i /etc/apt/sources.list && \
        && rm -rf /var/lib/apt/lists/*