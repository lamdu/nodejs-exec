#!/bin/sh

git submodule update --init --recursive

cd node
./configure --prefix=/tmp
make -j4
