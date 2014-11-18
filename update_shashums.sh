#!/bin/bash

if [[ ${NODE_VERSION:-false} == false ]]; then
    echo '${NODE_VERSION}' must be defined
    exit 1
fi

if [[ ${S3_URL:-false} == false ]]; then
    echo '${S3_URL}' must be defined
    exit 1
fi

if [ -n "$NAME" ]; then
    S3_URL="$S3_URL/$NAME"
fi

SCRATCH_DIR=/tmp/v${NODE_VERSION}-scratch
mkdir -p ${SCRATCH_DIR}
aws s3 cp --recursive ${S3_URL}/v${NODE_VERSION}/ ${SCRATCH_DIR}/
cd ${SCRATCH_DIR}
for i in $(ls ./*.*); do 
  shasum $i >> ./SHASUMS.txt
  shasum -a 256 $i >> ./SHASUMS256.txt
done
for i in $(ls ./x64/*.*); do 
  shasum $i >> ./SHASUMS.txt
  shasum -a 256 $i >> ./SHASUMS256.txt
done

aws s3 cp --acl public-read ./SHASUMS.txt ${S3_URL}/v${NODE_VERSION}/
aws s3 cp --acl public-read ./SHASUMS256.txt ${S3_URL}/v${NODE_VERSION}/
