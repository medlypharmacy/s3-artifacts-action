FROM python:3.8-alpine

ENV AWSCLI_VERSION='1.18.93'

RUN pip install --quiet --no-cache-dir awscli==${AWSCLI_VERSION}
RUN apk add openjdk11
RUN wget https://repo1.maven.org/maven2/io/swagger/codegen/v3/swagger-codegen-cli/3.0.20/swagger-codegen-cli-3.0.20.jar -O swagger-codegen-cli.jar

ENTRYPOINT ["/entrypoint.sh"]

COPY entrypoint.sh /entrypoint.sh