#!/usr/bin/env bash

TRAVIS_BUILD_ID=${TRAVIS_BUILD_ID:-"localdev"}
GithubAccessToken=${GithubAccessToken:-"dummy"}

set -e -u

TMP=$(mktemp -d -t node-cpp11.XXXX )
CWD=$(pwd)

ConfigJSON="$TMP/$TRAVIS_BUILD_ID-cfn.json"
UserData=$(node -e "
    var userdata = '';
    userdata += 'set AWS_ACCESS_KEY_ID=$BUILD_AWS_ACCESS_KEY_ID\n';
    userdata += 'set AWS_SECRET_ACCESS_KEY=$BUILD_AWS_SECRET_ACCESS_KEY\n';
    userdata += require('fs').readFileSync('$(dirname $0)/cfn_build_node.userdata.bat','utf8');
    console.log(JSON.stringify(userdata));
")
echo "{
    \"OS\": \"win2012-vs2014\",
    \"InstanceType\": \"c3.xlarge\",
    \"GithubAccessToken\": \"$GithubAccessToken\",
    \"UserData\": $UserData
}" >> $ConfigJSON

cd $TMP

# install node
mkdir -p $TMP
export PATH=$PATH:$TMP/bin
curl -s https://s3.amazonaws.com/mapbox/apps/install-node/v0.2.0/run | NV=0.10.33 NP=linux OD=$TMP sh

# install cfn-ci + cfn-config
npm install https://github.com/mapbox/cfn-ci/tarball/windows
npm install cfn-config@0.3.0

# create cfn stack for building
timeout 1200 $TMP/node_modules/.bin/cfn-create -f -r us-east-1 -n "travis-node-cpp11-$TRAVIS_BUILD_ID" -t $TMP/node_modules/cfn-ci/cfn-win.template -c $ConfigJSON || echo "cfn-create failed, cleaning up ..." &

# Node builds can take a long time.
# Output for travis to chew on to avoid 10 min "no output" timeout.
sleep 300
echo "..."
sleep 300
echo "..."

fg

wait

$TMP/node_modules/.bin/cfn-delete -f -r us-east-1 -n "travis-node-cpp11-$TRAVIS_BUILD_ID"

cd $CWD

rm -rf $TMP

