#!/usr/bin/env bash

if [[ ${NODE_VERSION:-false} == false ]]; then
    echo '${NODE_VERSION}' must be defined
    exit 1
fi

TRAVIS_JOB_ID=${TRAVIS_JOB_ID:-"localdev"}
COMMIT_MESSAGE=${COMMIT_MESSAGE:-"commit"}
GithubAccessToken=${GithubAccessToken:-"dummy"}

set -e -u

TMP=$(mktemp -d -t node-cpp11.XXXX )
CWD=$(pwd)

ConfigJSON="$TMP/$TRAVIS_JOB_ID-cfn.json"
UserData=$(node -e "
    var userdata = '';
    userdata += 'set NODE_VERSION=$NODE_VERSION\n';
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
npm install https://github.com/mapbox/cfn-config/tarball/aws-sdk-latest

# create cfn stack for building
timeout 1200 $TMP/node_modules/.bin/cfn-create -f -r us-east-1 -n "travis-node-cpp11-$TRAVIS_JOB_ID" -t $TMP/node_modules/cfn-ci/cfn-win.template -c $ConfigJSON || echo "cfn-create failed, cleaning up ..." &

# Node builds can take a long time.
# Output for travis to chew on to avoid 10 min "no output" timeout.
while [ $(jobs | grep -v Done | grep cfn-create | wc -l) -gt 0 ]; do
    sleep 60
    echo "    ..."
done

wait

if echo "$COMMIT_MESSAGE" | grep '\[publish debug\]' > /dev/null; then
    echo "Commit includes [publish debug] skipping stack teardown."
else
    $TMP/node_modules/.bin/cfn-delete -f -r us-east-1 -n "travis-node-cpp11-$TRAVIS_JOB_ID"
fi

cd $CWD

rm -rf $TMP

