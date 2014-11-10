#!/usr/bin/env bash

set -e

export COMMIT_MESSAGE=$(git show -s --format=%B $TRAVIS_COMMIT | tr -d '\n')

if ! echo "$COMMIT_MESSAGE" | grep '\[publish' > /dev/null; then
    echo "Include [publish] in commit message to build."
    exit 0
fi

# build node source tarball and publish
# commented until we need to build for a new node version
#AWS_ACCESS_KEY_ID=$MAPBOX_AWS_ACCESS_KEY_ID \
#AWS_SECRET_ACCESS_KEY=$MAPBOX_AWS_SECRET_ACCESS_KEY \
#./build_source.sh

# launches cfnci stack in sandbox
# passes BUILD_* keys to cfnci stack for publishing to mapbox bucket
AWS_ACCESS_KEY_ID=$SANDBOX_AWS_ACCESS_KEY_ID \
AWS_SECRET_ACCESS_KEY=$SANDBOX_AWS_SECRET_ACCESS_KEY \
BUILD_AWS_ACCESS_KEY_ID=$MAPBOX_AWS_ACCESS_KEY_ID \
BUILD_AWS_SECRET_ACCESS_KEY=$MAPBOX_AWS_SECRET_ACCESS_KEY \
./cfn_build_node.sh

# uploads shasums to mapbox bucket
AWS_ACCESS_KEY_ID=$MAPBOX_AWS_ACCESS_KEY_ID \
AWS_SECRET_ACCESS_KEY=$MAPBOX_AWS_SECRET_ACCESS_KEY \
./update_shashums.sh
