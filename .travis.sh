#!/usr/bin/env bash

set -e

export COMMIT_MESSAGE=$(git show -s --format=%B $TRAVIS_COMMIT | tr -d '\n')

if ! echo "$COMMIT_MESSAGE" | grep '\[publish' > /dev/null; then
    echo "Include [publish] in commit message to build."
    exit 0
fi

export platform=$(uname -s | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/")

if [[ ${platform} == 'linux' ]]; then
    # upgrade libstdc++ to support C++11
    sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
    sudo apt-get update -qqy
    sudo apt-get install -qqy libstdc++6 curl unzip python-pip
else if [[ ${platform} == 'darwin' ]]; then
    xcrun --sdk macosx --show-sdk-version; fi;
fi

sudo pip install awscli

if [[ ${platform} == 'linux' ]]; then
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

if [[ ${platform} == 'linux' ]]; then
    # uploads shasums to mapbox bucket
    AWS_ACCESS_KEY_ID=$MAPBOX_AWS_ACCESS_KEY_ID \
    AWS_SECRET_ACCESS_KEY=$MAPBOX_AWS_SECRET_ACCESS_KEY \
    ./update_shashums.sh
fi