FROM python:3.8-alpine

ENV AWSCLI_VERSION='1.18.93'

RUN pip install --quiet --no-cache-dir awscli==${AWSCLI_VERSION}

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
