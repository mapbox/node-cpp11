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

git clone ${REPO} -b ${BRANCH} $BUILD_DIR
cd $BUILD_DIR
./configure --prefix=$BUILD_DIR
export platform=$(uname -s | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/")
SOURCE_TARBALL=node-v${NODE_VERSION}.tar
# Node 5 and above has a tarball target that does not expect .gz
BINARY_TARBALL=node-v${NODE_VERSION}-${platform}-x64.tar
if [[ ${NODE_VERSION} =~ "0.10" ]] || [[ ${NODE_VERSION} =~ "0.12" ]]; then
    SOURCE_TARBALL="${SOURCE_TARBALL}.gz"
    BINARY_TARBALL="${BINARY_TARBALL}.gz"
fi

function upload() {
    aws s3 cp --acl=public-read ${1} ${S3_URL}/v${NODE_VERSION}/${1}
}

function try_upload() {
    if [[ -f ${SOURCE_TARBALL} ]]; then
        upload ${SOURCE_TARBALL}
    fi
    if [[ -f ${SOURCE_TARBALL}.gz ]]; then
        upload ${SOURCE_TARBALL}.gz
    fi
    if [[ -f ${SOURCE_TARBALL}.xz ]]; then
        upload ${SOURCE_TARBALL}.xz
    fi
}

if [[ ${platform} == 'linux' ]]; then
    make V= -j${JOBS} ${SOURCE_TARBALL}
    try_upload ${SOURCE_TARBALL}
fi

make V= -j${JOBS} ${BINARY_TARBALL}
try_upload ${BINARY_TARBALL}

cd $CWD
