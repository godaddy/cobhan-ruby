#!/bin/sh
set -euo

LIB_NAME="libcobhandemo"
DYN_EXT="so"
SYS_FN_PART="arm64"
GOARCH="arm64"
OUTPUT_FILE="$LIB_NAME-$SYS_FN_PART.$DYN_EXT"
DOCKER_IMG=golang:1.20.5-bullseye
BUILD_CMD="GOOS=linux GOARCH=$GOARCH go build -buildmode=c-shared -ldflags='-s -w' -o $OUTPUT_FILE $LIB_NAME.go"
BUILD_DIR="tmp/build/linux-arm64"

SRC_DIR="spec/support/$LIB_NAME"
mkdir -p $BUILD_DIR
cp -R $SRC_DIR/* $BUILD_DIR

# Build Linux arm64 binary
docker run --rm --name cobhan-builder \
  --volume "$(pwd)/$BUILD_DIR":/usr/src/cobhan \
  --platform=linux/arm64/v8 \
  -w /usr/src/cobhan \
  $DOCKER_IMG \
  sh -c "$BUILD_CMD"

# Move the binary to tmp
cp $BUILD_DIR/$OUTPUT_FILE tmp/

# Enable execution of different multi-architecture containers
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

# Run tests inside docker on Linux arm64
docker run --rm --name cobhan-builder \
  --volume "$(pwd)":/usr/src/cobhan \
  --platform=linux/arm64/v8 \
  -w /usr/src/cobhan \
  ruby:3.1.0-bullseye \
  sh -c "bundle install; bundle exec rspec spec"
