# C++11 enabled builds of node

[![Build Status](https://travis-ci.org/mapbox/node-cpp11.svg?branch=master)](https://travis-ci.org/mapbox/node-cpp11)

## Downloads:

### OS X

v0.10.33
 - x64: https://mapbox.s3.amazonaws.com/node-cpp11/v0.10.33/node-v0.10.33-darwin-x64.tar.gz

v0.10.40
 - x64: https://mapbox.s3.amazonaws.com/node-cpp11/v0.10.40/node-v0.10.40-darwin-x64.tar.gz

v0.11.14
 - x64: https://mapbox.s3.amazonaws.com/node-cpp11/v0.11.14/node-v0.11.14-darwin-x64.tar.gz

v0.12.0
 - x64: https://mapbox.s3.amazonaws.com/node-cpp11/v0.12.0/node-v0.12.0-darwin-x64.tar.gz

v0.12.2
 - x64: https://mapbox.s3.amazonaws.com/node-cpp11/v0.12.2/node-v0.12.2-darwin-x64.tar.gz

v0.12.7
 - x64: https://mapbox.s3.amazonaws.com/node-cpp11/v0.12.7/node-v0.12.7-darwin-x64.tar.gz

### Linux

v0.10.33
 - x64: https://mapbox.s3.amazonaws.com/node-cpp11/v0.10.33/node-v0.10.33-linux-x64.tar.gz

v0.10.40
 - x64: https://mapbox.s3.amazonaws.com/node-cpp11/v0.10.40/node-v0.10.40-linux-x64.tar.gz

v0.11.14
 - x64: https://mapbox.s3.amazonaws.com/node-cpp11/v0.11.14/node-v0.11.14-linux-x64.tar.gz

v0.12.0
 - x64: https://mapbox.s3.amazonaws.com/node-cpp11/v0.12.0/node-v0.12.0-linux-x64.tar.gz

v0.12.2
 - x64: https://mapbox.s3.amazonaws.com/node-cpp11/v0.12.2/node-v0.12.2-linux-x64.tar.gz

v0.12.7
 - x64: https://mapbox.s3.amazonaws.com/node-cpp11/v0.12.7/node-v0.12.7-linux-x64.tar.gz

### Windows

#### Redistributable Visual Studio 2015 installers:
 - x64: https://mapbox.s3.amazonaws.com/windows-builds/visual-studio-runtimes/vcredist-VS2015/vcredist_x64.exe 
 - x86: https://mapbox.s3.amazonaws.com/windows-builds/visual-studio-runtimes/vcredist-VS2015/vcredist_x86.exe 

#### Node for Windows / Visual Studio 2015

v0.10.33
 - x64: https://mapbox.s3.amazonaws.com/node-cpp11/v0.10.33/x64/node.exe
 - x86: https://mapbox.s3.amazonaws.com/node-cpp11/v0.10.33/node.exe

v0.10.40
 - x64: https://mapbox.s3.amazonaws.com/node-cpp11/v0.10.40/x64/node.exe
 - x86: https://mapbox.s3.amazonaws.com/node-cpp11/v0.10.40/node.exe

v0.12.0
 - x64: https://mapbox.s3.amazonaws.com/node-cpp11/v0.12.0/x64/node.exe
 - x86: https://mapbox.s3.amazonaws.com/node-cpp11/v0.12.0/node.exe

v0.12.2
 - x64: https://mapbox.s3.amazonaws.com/node-cpp11/v0.12.2/x64/node.exe
 - x86: https://mapbox.s3.amazonaws.com/node-cpp11/v0.12.2/node.exe

v0.12.7
 - x64: https://mapbox.s3.amazonaws.com/node-cpp11/v0.12.7/x64/node.exe
 - x86: https://mapbox.s3.amazonaws.com/node-cpp11/v0.12.7/node.exe

## Adding new node version

- head over to https://github.com/mapbox/node
- clone, add remote, port patches forward:

```
NODE_VERSION=0.12.7
git clone git@github.com:mapbox/node.git
cd node
git remote add joyent git@github.com:joyent/node.git
git fetch joyent
git checkout v${NODE_VERSION}-release
git push origin v${NODE_VERSION}-release
git branch v${NODE_VERSION}-nodecpp11
git checkout v${NODE_VERSION}-nodecpp11
# diff out latest version ported
git diff joyent/v0.12.2-release origin/v0.12.2-nodecpp11 > v12.diff
```

- manually integrate the `v12.diff` patch (very unlikely that `git apply v12.diff` will work)
- then commit:

```
git commit -a -m "apply c++11 patches"
git push origin v0.12.7-nodecpp11
```
- Optional: create a pull request (AGAINST mapbox/node) with the fixes so we have something to link to (like https://github.com/mapbox/node/pull/7)
- Optional: Test that it builds locally on a windows machine (to save time debugging if it will not yet build)
- Add it to the versions that automatically get built by this repo: https://github.com/mapbox/node-cpp11/blob/master/.travis.yml#L10-L14
- Commit to this repo like:

```
git commit -m "[publish]"
```
