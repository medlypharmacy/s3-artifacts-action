#Upload Artifacts to S3

The purpose of this action is to upload the zipped artifact from github actions and upload it to S3, segregated by repository and branch. 

This allows the organisation to package and upload all their artifacts to the same S3 bucket for deployment.

##Usage

This action requires 5 inputs: S3 Bucket Name, AWS Access Key Id, Secret Access Key, AWS Region, and the name of the zipped distribution file created by the github action.

The following a snippet of how this can be used. You can also find the same example snippet is also available at ```.github/workflows/build.yml``` of this repository

```yaml

name: build

on: [push, pull_request]

jobs:
  publish-s3-artifact:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Upload to S3 as artifact
        uses: medlypharmacy/s3-artifacts-action@master
        with:
          aws_access_key_id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws_secret_access_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws_region: us-east-1
          dist_file_path: './dummy91.zip'
          aws_s3_bucket_name: ${{ secrets.AWS_S3_BUCKET_NAME }}
```