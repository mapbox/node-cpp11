#!/usr/bin/env bash

set -e

export COMMIT_MESSAGE=$(git show -s --format=%B $TRAVIS_COMMIT | tr -d '\n')

pip install --user awscli


#if [[ $(uname -s) == 'Linux' ]] && [[ ${COMMIT_MESSAGE} =~ "[publish]" ]]; then
    # uploads shasums to mapbox bucket
    AWS_ACCESS_KEY_ID=$MAPBOX_AWS_ACCESS_KEY_ID \
    AWS_SECRET_ACCESS_KEY=$MAPBOX_AWS_SECRET_ACCESS_KEY \
    ./update_shashums.sh
#fi