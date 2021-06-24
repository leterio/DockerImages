FROM python:rc-alpine

LABEL maintainer="Vinícius Letério <viniciusleterio@gmail.com>"

RUN pip install speedtest-cli && \
    pip cache purge

entrypoint ["/usr/local/bin/python", "/usr/local/bin/speedtest-cli"]
