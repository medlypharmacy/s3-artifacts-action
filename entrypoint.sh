#!/bin/sh

set -e

if [[ -z "$INPUT_AWS-ACCESS-KEY-ID" || \
      -z "$INPUT_SECRET-ACCESS-KEY" || \
      -z "$INPUT_AWS-REGION" ]]; then
  echo "Please provide AWS credentials and region."
  exit 1
fi

if [[ -z "$INPUT_AWS-S3-BUCKET-NAME" || \
      -z "$INPUT_DIST-FILE-PATH" ]]; then
  echo "Please provide S3 bucket and local dist file."
  exit 1
fi

aws configure --profile upload-artifacts-profile <<-EOF > /dev/null 2>&1
${INPUT_AWS-ACCESS-KEY-ID}
${INPUT_AWS-SECRET-ACCESS-KEY}
${INPUT_AWS-REGION}
text
EOF

BRANCH_NAME=$(echo $GITHUB_REF | cut -d'/' -f 3)
REPO_NAME=$(echo $GITHUB_REPOSITORY | cut -d'/' -f 2)

sh -c "aws s3 cp ${INPUT_DIST-FILE-PATH} s3://${INPUT_AWS-S3-BUCKET-NAME}/${REPO_NAME}/${BRANCH_NAME}/${GITHUB_RUN_NUMBER}.zip \
              --profile upload-artifacts-profile \
              --no-progress" 

aws configure --profile upload-artifacts-profile <<-EOF > /dev/null 2>&1
null
null
null
text
EOF
