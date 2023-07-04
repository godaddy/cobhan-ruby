#!/bin/sh
set -euo

LIB_NAME=libcobhandemo
ROOT_DIR=$(pwd)
SRC_DIR="spec/support/$LIB_NAME"

# Normalize machine architecture for file names
case $(uname -m) in
  "x86_64")
    SYS_FN_PART="x64"
    GOARCH="amd64"
    ;;
  "aarch64" | "arm64")
    SYS_FN_PART="arm64"
    GOARCH="arm64"
    ;;
  *)
    echo "Unknown machine $(uname -m)!"
    exit 255
    ;;
esac

# OS Detection
case $(uname -s) in
  "Darwin")
    OUTPUT_FILE="$LIB_NAME-$SYS_FN_PART.dylib"
    BUILD_CMD="GOOS=darwin GOARCH=$GOARCH go build -buildmode=c-shared -ldflags='-s -w' -o $OUTPUT_FILE $LIB_NAME.go"
    BUILD_DIR="tmp/build/darwin"
    ;;
  "Linux")
    OUTPUT_FILE="$LIB_NAME-$SYS_FN_PART.so"
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
cd $BUILD_DIR

echo "$BUILD_CMD"
sh -c "$BUILD_CMD"
cd "$ROOT_DIR"
cp $BUILD_DIR/$OUTPUT_FILE tmp/
