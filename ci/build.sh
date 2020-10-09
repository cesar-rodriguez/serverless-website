#!/bin/bash

S3_BUCKET="cesar-serverless-website-staging"

package () {
    echo "Creating zip file"
    zip lambda.zip main.py
}

stage () {
    echo "Moving zip file to S3 for staging"
    VERSION=$1
    aws s3 cp lambda.zip s3://${S3_BUCKET}/v${VERSION}/lambda.zip
}

cleanup () {
    echo "Removing zip"
    rm lambda.zip
}

terminate () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || terminate "1 argument required, $# provided"

package
stage $1
cleanup
