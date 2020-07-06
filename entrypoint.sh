#!/bin/sh

set -e

if [[ -z "$AWS_ACCESS_KEY_ID" || \
      -z "$AWS_SECRET_ACCESS_KEY" || \
      -z "$AWS_REGION" ]]; then
  echo "Please provide AWS credentials and region."
  exit 1
fi

if [[ -z "$AWS_S3_BUCKET_NAME" || \
      -z "$DIST_FILE_PATH" ]]; then
  echo "Please provide S3 bucket and local dist file."
  exit 1
fi

aws configure --profile upload-artifacts-profile <<-EOF > /dev/null 2>&1
${AWS_ACCESS_KEY_ID}
${AWS_SECRET_ACCESS_KEY}
${AWS_REGION}
text
EOF

BRANCH_NAME=$(echo $GITHUB_REF | cut -d'/' -f 3)
REPO_NAME=$(echo $GITHUB_REPOSITORY | cut -d'/' -f 2)

sh -c "aws s3 cp ${DIST_FILE_PATH} s3://${AWS_S3_BUCKET_NAME}/${REPO_NAME}/${BRANCH_NAME}/${GITHUB_RUN_NUMBER}.zip \
              --profile upload-artifacts-profile \
              --no-progress" 

aws configure --profile upload-artifacts-profile <<-EOF > /dev/null 2>&1
null
null
null
text
EOF
