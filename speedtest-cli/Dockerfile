FROM python:rc-alpine

LABEL maintainer="Vinícius Letério <viniciusleterio@gmail.com>"

RUN pip install speedtest-cli && \
    pip cache purge

ENTRYPOINT ["/usr/local/bin/python", "/usr/local/bin/speedtest-cli"]
