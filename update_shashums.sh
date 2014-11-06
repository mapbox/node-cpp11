#!/bin/bash

SCRATCH_DIR=/tmp/${NODE_VERSION}
mkdir -p ${SCRATCH_DIR}
aws s3 cp --recursive ${S3_URL}/${NODE_VERSION} ${SCRATCH_DIR}
cd ${SCRATCH_DIR}
for i in $(ls ./*.*); do 
  shasum $i >> ./SHASUMS.txt
  shasum -a 256 $i >> ./SHASUMS256.txt
done
for i in $(ls ./x64/*.*); do 
  shasum $i >> ./SHASUMS.txt
  shasum -a 256 $i >> ./SHASUMS256.txt
done

aws s3 cp --acl public-read ./SHASUMS.txt ${S3_URL}/${NODE_VERSION}/
aws s3 cp --acl public-read ./SHASUMS256.txt ${S3_URL}/${NODE_VERSION}/