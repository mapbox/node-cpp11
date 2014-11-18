#!/bin/bash

if [[ ${NODE_VERSION:-false} == false ]]; then
    echo '${NODE_VERSION}' must be defined
    exit 1
fi

if [[ ${S3_URL:-false} == false ]]; then
    echo '${S3_URL}' must be defined
    exit 1
fi

if [[ ${WINCERT_PASSWORD:-false} == false ]]; then
    echo '${WINCERT_PASSWORD}' must be defined
    exit 1
fi

if [ -n "$NAME" ]; then
    S3_URL="$S3_URL/$NAME"
fi

set -e -u

TMP=/tmp/v${NODE_VERSION}-signing
mkdir -p ${TMP}/x64

# Download built node
aws s3 cp ${S3_URL}/v${NODE_VERSION}/node.exe ${TMP}/
aws s3 cp ${S3_URL}/v${NODE_VERSION}/x64/node.exe ${TMP}/x64/

# Download signing cert
aws s3 cp s3://mapbox/mapbox-studio/certs/authenticode.spc $TMP/authenticode.spc
aws s3 cp s3://mapbox/mapbox-studio/certs/authenticode.pvk $TMP/authenticode.pvk

# Install windowsign
npm install -g https://github.com/mapbox/windowsign/archive/v0.0.1.tar.gz

# Sign node.exe files
for FILE in $TMP/node.exe $TMP/x64/node.exe; do
    N=node.js \
    I=https://www.mapbox.com \
    P=$WINCERT_PASSWORD \
    SPC=$TMP/authenticode.spc \
    PVK=$TMP/authenticode.pvk \
    windowsign $FILE
done

# Remove signing certs
rm -f $TMP/authenticode.spc $TMP/authenticode.pvk

# Upload signed versions
aws s3 cp --acl=public-read $TMP/node.exe ${S3_URL}/v${NODE_VERSION}/node.exe
aws s3 cp --acl=public-read $TMP/x64/node.exe ${S3_URL}/v${NODE_VERSION}/x64/node.exe

# Cleanup
rm -rf $TMP

