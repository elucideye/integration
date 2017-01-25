#!/bin/bash

# must be run from root folder:

# MY_IOS_IDENTITY="iPhone Developer: You Name (XXXXXXXXXX)"

if [ -z "${MY_IOS_IDENTITY}" ]; then
    echo 2>&1 "Must have MY_IOS_IDENTITY set"
    exit 1
fi

TOOLCHAIN=ios-10-1-dep-8-0-hid-sections

MYLIB_DIR="${PWD}/mylib/_framework/${TOOLCHAIN}"

COMMANDS=(
    "--config=Release "
    "--verbose "
    "--fwd "
    "CMAKE_XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET=8.0 "
    "--jobs 8 "
    "--reconfig "
    "--clear "
)

FRAMEWORK_ARGS=(
    "--framework-device "
    "--ios-multiarch "
    "--ios-combined "
    "--archive mylib "
    "--plist ${PWD}/mylib/cmake/framework/Info.plist "    
)

( # Build shared library:
    cd mylib
    polly.py --toolchain ${TOOLCHAIN} ${FRAMEWORK_ARGS[*]} ${COMMANDS[*]} --identity "${MY_IOS_IDENTITY}" --install # --open --nobuild
)

( # Emulate 3rd-party consumer of shared library:
    cd yourapp
    polly.py --toolchain ${TOOLCHAIN} ${COMMANDS[*]} --fwd "MYLIB_DIR=${MYLIB_DIR}" --open
)

echo "1) File -> Add Files To Your App : mylib/_framework/${TOOLCHAIN}/mylib.framework"
echo "2) Target = yourapp; General -> Embed Binaries -> + -> mylib.framework"
echo "Run... create crash"
echo "See: http://stackoverflow.com/a/39714542"

