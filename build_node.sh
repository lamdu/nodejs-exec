#!/bin/bash

# adapted from https://apple.stackexchange.com/a/123408/11374
function version { echo "${@//v}" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

NODE_VERSION=`node --version`

if [ $(version "$NODE_VERSION") -ge $(version "v6.2.1") ]; then
    echo "Using existing system node $NODE_VERSION"
    cp `which node` node/node
else
    echo "Building nodejs from source"
    # node not available or too old. Build from source.
    git submodule update --init --recursive
    cd node
    ./configure --prefix=/tmp
    make -j4
fi
