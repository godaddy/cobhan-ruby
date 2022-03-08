#!/bin/sh
set -euo

LIB_NAME=libcobhandemo
SRC_DIR="spec/support/$LIB_NAME"

# Normalize machine architecture for file names
case $(uname -m) in
  "x86_64")
    SYS_FN_PART="x64"
    GOARCH="amd64"
    ;;
  *)
    echo "Unknown machine $(uname -m)!"
    exit 255
    ;;
esac

# OS Detection
case $(uname -s) in
  "Darwin")
    DYN_EXT="dylib"
    OUTPUT_FILE="$LIB_NAME-$SYS_FN_PART.$DYN_EXT"
    DOCKER_IMG=neilotoole/xcgo:go1.17
    BUILD_CMD="GOOS=darwin GOARCH=$GOARCH CC=o64-clang CXX=o64-clang++ go build -buildmode=c-shared -ldflags='-s -w' -o $OUTPUT_FILE $LIB_NAME.go"
    BUILD_DIR="tmp/build/darwin"
    ;;
  "Linux")
    DYN_EXT="so"
    OUTPUT_FILE="$LIB_NAME-$SYS_FN_PART.$DYN_EXT"
    DOCKER_IMG=golang:1.17.7-bullseye
    BUILD_CMD="GOOS=linux GOARCH=$GOARCH go build -buildmode=c-shared -ldflags='-s -w' -o $OUTPUT_FILE $LIB_NAME.go"
    BUILD_DIR="tmp/build/linux"
    ;;
  *)
    echo "Unknown system $(uname -s)!"
    exit 255
    ;;
esac

mkdir -p $BUILD_DIR
cp -R $SRC_DIR/* $BUILD_DIR

# Debug
echo $BUILD_CMD
# docker run -it --rm --name cobhan-builder \
#   --volume "$(pwd)/$BUILD_DIR":/usr/src/cobhan \
#   -w /usr/src/cobhan \
#   $DOCKER_IMG \
#   bash

docker run --rm --name cobhan-builder \
  --volume "$(pwd)/$BUILD_DIR":/usr/src/cobhan \
  -w /usr/src/cobhan \
  $DOCKER_IMG \
  sh -c "$BUILD_CMD"

cp $BUILD_DIR/$OUTPUT_FILE tmp/
