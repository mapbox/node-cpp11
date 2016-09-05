#!/usr/bin/env bash

set -e

export COMMIT_MESSAGE=$(git show -s --format=%B $TRAVIS_COMMIT | tr -d '\n')

pip install --user awscli

if [[ ${COMMIT_MESSAGE} =~ "[publish]" ]] && [[ $(uname -s) == 'Linux' ]]; then
    # launches cfnci stack in sandbox
    # passes BUILD_* keys to cfnci stack for publishing to mapbox bucket
    AWS_ACCESS_KEY_ID=$SANDBOX_AWS_ACCESS_KEY_ID \
    AWS_SECRET_ACCESS_KEY=$SANDBOX_AWS_SECRET_ACCESS_KEY \
    BUILD_AWS_ACCESS_KEY_ID=$MAPBOX_AWS_ACCESS_KEY_ID \
    BUILD_AWS_SECRET_ACCESS_KEY=$MAPBOX_AWS_SECRET_ACCESS_KEY \
    ./cfn_build_node.sh

    # sign node binaries
    AWS_ACCESS_KEY_ID=$MAPBOX_AWS_ACCESS_KEY_ID \
    AWS_SECRET_ACCESS_KEY=$MAPBOX_AWS_SECRET_ACCESS_KEY \
    ./sign_node.sh
fi

# build node source tarball and publish
AWS_ACCESS_KEY_ID=$MAPBOX_AWS_ACCESS_KEY_ID \
AWS_SECRET_ACCESS_KEY=$MAPBOX_AWS_SECRET_ACCESS_KEY \
./build_source.sh

if [[ $(uname -s) == 'Linux' ]] && [[ ${COMMIT_MESSAGE} =~ "[publish]" ]]; then
    # uploads shasums to mapbox bucket
    AWS_ACCESS_KEY_ID=$MAPBOX_AWS_ACCESS_KEY_ID \
    AWS_SECRET_ACCESS_KEY=$MAPBOX_AWS_SECRET_ACCESS_KEY \
    ./update_shashums.sh
fi