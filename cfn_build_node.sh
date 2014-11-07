#!/usr/bin/env bash

TRAVIS_BUILD_ID=${TRAVIS_BUILD_ID:-"localdev"}

set -e -u

TMP=$(mktemp -d -t node-cpp11.XXXX )
CWD=$(pwd)

cd $TMP

# install node
mkdir -p $TMP
export PATH=$PATH:$TMP/bin
curl -s https://s3.amazonaws.com/mapbox/apps/install-node/v0.2.0/run | NV=0.10.33 NP=linux OD=$TMP sh

# install cfn-ci + cfn-config
npm install https://github.com/mapbox/cfn-ci/tarball/windows
npm install cfn-config@0.3.0

GithubAccessToken="dummytoken"
ConfigJSON="$TMP/$TRAVIS_BUILD_ID-cfn.json"
echo "{
    \"OS\": \"win2012-vs2014\",
    \"GithubAccessToken\": \"$GithubAccessToken\",
    \"UserData\": \"call cinst git.install\ncall git clone -b windows https://github.com/mapbox/node-cpp11 Z:\\\\node-cpp11\ncall Z:\\\\node-cpp11\\\\windows\\\\install.bat\"
}" >> $ConfigJSON

# create cfn stack for building
$TMP/node_modules/.bin/cfn-create -f -r us-east-1 -n "node-cpp11-$TRAVIS_BUILD_ID" -t $TMP/node_modules/cfn-ci/cfn-win.template -c $ConfigJSON || echo "cfn-create failed, cleaning up ..."

# $(dirname $0)/../node_modules/.bin/cfn-delete -f -r us-east-1 -n "node-cpp11-$TRAVIS_BUILD_ID-$Context"

cd $CWD

rm -rf $TMP

