ARG UBUNTU_IMAGE_VERSION

FROM ubuntu:${UBUNTU_IMAGE_VERSION}

#sed 's+http://archive.ubuntu.com/ubuntu/+http://mirror.uepg.br/ubuntu/+g' -i /etc/apt/sources.list \
#&& sed 's+http://mirror.uepg.br/ubuntu/+http://archive.ubuntu.com/ubuntu/+g' -i /etc/apt/sources.list \
RUN cat /etc/os-release \
        && apt-get update \
        && apt-get install -y \
            build-essential \
            libssl-dev \
            git \
        && rm -rf /var/lib/apt/lists/*