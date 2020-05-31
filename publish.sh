#!/bin/bash -x

git checkout master

image=jmlopez-rod
targetDir=.

podman create -it --name unpack "$image" bash || exit 1
podman cp unpack:/_site/. "$targetDir" || exit 1
podman rm -f unpack
