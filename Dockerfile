FROM python:3.8-alpine

ENV AWSCLI_VERSION='1.18.93'

RUN pip install --quiet --no-cache-dir awscli==${AWSCLI_VERSION}
RUN apk add openjdk11
RUN apk add nodejs nodejs-npm
RUN npm install -g redoc-cli@0.9.10
RUN npm install -g @asyncapi/generator@0.50.0
RUN npm install -g @openapitools/openapi-generator-cli

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
