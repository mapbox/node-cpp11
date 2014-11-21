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
./configure --prefix=$BUILD_DIR
if [[ ${platform} == 'linux' ]]; then
    SOURCE_TARBALL=node-v${NODE_VERSION}.tar.gz
    make -j${JOBS} ${SOURCE_TARBALL}
    aws s3 cp --acl=public-read ${SOURCE_TARBALL} ${S3_URL}/v${NODE_VERSION}/${SOURCE_TARBALL}
fi
BINARY_TARBALL=node-v${NODE_VERSION}-${platform}-x64.tar.gz
make -j${JOBS} ${BINARY_TARBALL}
aws s3 cp --acl=public-read ${BINARY_TARBALL} ${S3_URL}/v${NODE_VERSION}/${BINARY_TARBALL}

cd $CWD
