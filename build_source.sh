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

set -e -u

CWD=$(pwd)
BUILD_DIR=/tmp/v${NODE_VERSION}

git clone https://github.com/mapbox/node.git -b ${BRANCH} $BUILD_DIR
cd $BUILD_DIR
# on travis this should find /usr/local/clang-3.4/bin/clang++
export CC=clang
export CXX=clang++
./configure --prefix=$BUILD_DIR
make -j${JOBS} node-v${NODE_VERSION}.tar.gz
aws s3 cp --acl=public-read node-v${NODE_VERSION}.tar.gz ${S3_URL}/v${NODE_VERSION}/node-v${NODE_VERSION}.tar.gz

cd $CWD
