#!/bin/sh

set -e

[ -z $INPUT_AWS_S3_BUCKET_NAME ] && INPUT_AWS_S3_BUCKET_NAME="medly-dev-build-artifacts"
[ -z $INPUT_AWS_REGION ] && INPUT_AWS_REGION="us-east-1"
[ -z $INPUT_RESOURCE_TYPE ] && INPUT_RESOURCE_TYPE="FILE"

if [[ -z "$INPUT_AWS_ACCESS_KEY_ID" || \
      -z "$INPUT_AWS_SECRET_ACCESS_KEY" ]]; then
  echo "Please provide AWS credentials."
  exit 1
fi

if [[ -z "$INPUT_SOURCE_PATH" ]]; then
  echo "Please provide local dist file."
  exit 1
fi

aws configure --profile upload-artifacts-profile <<-EOF > /dev/null 2>&1
${INPUT_AWS_ACCESS_KEY_ID}
${INPUT_AWS_SECRET_ACCESS_KEY}
${INPUT_AWS_REGION}
text
EOF

BRANCH_NAME=$(echo $GITHUB_REF | cut -d'/' -f 3)
REPO_NAME=$(echo $GITHUB_REPOSITORY | cut -d'/' -f 2)
METADATA="{\\\"initiator\\\":\\\"$GITHUB_ACTOR\\\",\\\"commit_sha\\\":\\\"$GITHUB_SHA\\\"}"


if [[ -z "$INPUT_DESTINATION_PATH" ]]; then
  DESTINATION_PATH=${BRANCH_NAME}/${GITHUB_RUN_NUMBER}.zip
else
  DESTINATION_PATH=$(echo $INPUT_DESTINATION_PATH | sed 's/\.*\/*//')
fi

if [[ $INPUT_RESOURCE_TYPE == 'SWAGGER_TO_HTML' ]]; then
  if [[ -f "$INPUT_SOURCE_PATH" ]]; then
    echo "Source path must be a directory for the resource type SWAGGER_TO_HTML"
    exit 1
  fi
  SWAGGER_SPECIFICATION_FILES=$(ls $INPUT_SOURCE_PATH/*.yml)
  for SWAGGER_SPECIFICATION_FILE in $SWAGGER_SPECIFICATION_FILES
  do
    echo "Generating html docs for: $SWAGGER_SPECIFICATION_FILE"
    SWAGGER_SPECIFICATION_FILE_NAME="$(basename -- $SWAGGER_SPECIFICATION_FILE)"
    redoc-cli bundle \
          $SWAGGER_SPECIFICATION_FILE \
          -o "/tmp/${SWAGGER_SPECIFICATION_FILE_NAME%.*}/index.html"
  done
  INPUT_SOURCE_PATH=/tmp
  DESTINATION_PATH=swagger-docs
fi

if [[ $INPUT_RESOURCE_TYPE == 'TEST_COVERAGE' ]]; then
  if [[ -f "$INPUT_SOURCE_PATH" ]]; then
    echo "Source path must be a directory for the resource type TEST_COVERAGE"
    exit 1
  fi
  DESTINATION_PATH=test-coverage
fi

[[ $INPUT_RESOURCE_TYPE == 'FILE' ]] && ARGS="" || ARGS="--recursive"

sh -c "aws s3 cp ${INPUT_SOURCE_PATH} s3://${INPUT_AWS_S3_BUCKET_NAME}/${REPO_NAME}/${DESTINATION_PATH} \
        --profile upload-artifacts-profile \
        --no-progress \
        --metadata $METADATA $ARGS"

aws configure --profile upload-artifacts-profile <<-EOF > /dev/null 2>&1
null
null
null
text
EOF
