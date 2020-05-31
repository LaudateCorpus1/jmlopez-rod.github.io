#!/bin/bash -x

git checkout master

image=jmlopez-rod
targetDir=.

docker create -it --name unpack "$image" bash || exit 1
docker cp unpack:/_site/. "$targetDir" || exit 1
docker rm -f unpack
