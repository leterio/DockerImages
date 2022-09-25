FROM python:alpine

LABEL maintainer="Vinícius Letério <viniciusleterio@gmail.com>"

RUN apk --no-cache --no-progress upgrade && \
    pip install speedtest-cli && \
    pip cache purge

ENTRYPOINT ["/usr/local/bin/python", "/usr/local/bin/speedtest-cli"]
