#!/bin/bash

mkdir -p bin

# adapted from https://apple.stackexchange.com/a/123408/11374
function version { echo "${@//v}" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

NODE_VERSION=`node --version`
VER=$(version "$NODE_VERSION")

if [[ $(version "v6.2.1") -le $VER && $VER -lt $(version "v8.0.0") ]]; then
    # According to http://node.green/ support of tail calls exists in these versions
    echo "Using existing system node $NODE_VERSION"
    cp "$(which node)" bin/node.exe
else
    echo "Building nodejs from source"
    # node not available or too old. Build from source.
    git clone --depth 1 -b v6.11.3 https://github.com/nodejs/node.git
    cd node
    ./configure --prefix=/tmp
    make -j4
    cd ..
    cp node/node bin/node.exe
fi
