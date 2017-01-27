#!/bin/bash -x

set -e

# Includes
. bin/ios-toolchain.sh

CRASH_LOG=$1

if [ -z "${CRASH_LOG}" ]; then
    2>&1 echo "Myst specify valid *.crash file"
    exit 1
fi

# Use operative toolchain for path formation:
TOOLCHAIN=ios-10-1-dep-8-0-hid-sections

# Find xcode path programmatically:
XCODE_DIR="$(xcrun --show-sdk-path | sed -E 's|^(.*)/Contents/.*|\1|g')"

# Set DEVELOPER_DIR for symbolicatecrash tool:
export DEVELOPER_DIR="${XCODE_DIR}/Contents/Developer"

# Add symbolicatecrash app to the path:
PATH="${PATH}:${XCODE_DIR}/Contents/SharedFrameworks/DVTFoundation.framework/Versions/A/Resources/"

# Place .crash and .dSYM in same directory
mkdir -p _sandbox
tar zcvf _sandbox/staging.tgz -C mylib/_builds/${TOOLCHAIN}/Release-iphoneos libmylib.dylib.dSYM

(
    cd _sandbox
    tar zxvf staging.tgz
    cp ${CRASH_LOG} .
    symbolicatecrash ${CRASH_LOG} libmylib.dylib.dSYM
)



