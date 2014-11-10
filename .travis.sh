#!/usr/bin/env bash

set -e

# build node source tarball and publish
AWS_ACCESS_KEY_ID=$MAPBOX_AWS_ACCESS_KEY_ID \
AWS_SECRET_ACCESS_KEY=$MAPBOX_AWS_SECRET_ACCESS_KEY \
./build_source.sh

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
