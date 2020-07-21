#!/bin/sh

set -e

[ -z $INPUT_AWS_S3_BUCKET_NAME ] && INPUT_AWS_S3_BUCKET_NAME="medly-dev-build-artifacts"
[ -z $INPUT_AWS_REGION ] && INPUT_AWS_REGION="us-east-1"

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
  DESTINATION_PATH=$INPUT_DESTINATION_PATH
fi

[[ $INPUT_RESOURCE_TYPE == 'DIRECTORY' ]] && ARGS=" --recursive" || ARGS=""

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