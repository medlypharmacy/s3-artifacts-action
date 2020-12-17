'use strict';
const core = require('@actions/core');
const s3 = require('s3');
const { once } = require('events');

function validateCredentials(awsAccessKeyId, awsSecretAccessKey){
    if ( !awsAccessKeyId || !awsSecretAccessKey )
        throw 'Please provide AWS credentials.'
}

function validateSourcePath(sourcePath){
    if ( ! sourcePath )
        throw 'Please provide local dist file.'
}

function setDestinationPath(resourceType){
    switch (resourceType){
        case 'FILE':
            const branchName=process.env.GITHUB_REF.split('/').slice(2).join('-');
            destinationPath = `${branchName}/${process.env.GITHUB_RUN_NUMBER}.zip`;
            break;
        case 'SWAGGER_TO_HTML':
            destinationPath = 'swagger-docs';
            break;
        case 'ASYNCAPI_TO_HTML':
            destinationPath = 'asyncapi-docs';
            break;
        case 'TEST_COVERAGE':
            destinationPath = 'test-coverage';
    }

    return destinationPath;
}

try {
    const awsAccessKeyId = core.getInput('aws_access_key_id');
    const awsSecretAccessKey = core.getInput('aws_secret_access_key');
    const awsRegion = core.getInput('aws_region') || 'us-east-1';
    const awsS3BucketName = core.getInput('aws_s3_bucket_name') || 'medly-dev-build-artifacts';
    const sourcePath = core.getInput('source_path');
    const resourceType = core.getInput('resource_type') || 'FILE';
    var destinationPath = core.getInput('destination_path');

    validateCredentials(awsAccessKeyId,awsSecretAccessKey);
    validateSourcePath(sourcePath);

    const repoName=process.env.GITHUB_REPOSITORY.split('/')[1];
    const metadata={
    initiator: process.env.GITHUB_ACTOR,
    commit_sha:process.env.GITHUB_SHA
    }

    destinationPath = destinationPath || setDestinationPath(resourceType);

    const s3Client = s3.createClient({
        s3Options: {
            accessKeyId: awsAccessKeyId,
            secretAccessKey: awsSecretAccessKey,
            region: awsRegion
        }
    });

    const params = {
        localFile: sourcePath,

        s3Params: {
            Bucket: awsS3BucketName,
            Key: `${repoName}/${destinationPath}`,
            Metadata: metadata
        }
    };

    console.log(params);

    async function upload(){
        var uploader = s3Client.uploadFile(params);
        await once(uploader,'end')
    }

    upload()
        .then(data => {
            console.log("Artifact Uploaded");
        })
        .catch(err => console.log(err));

} catch (error) {
  core.setFailed(error.message);
}