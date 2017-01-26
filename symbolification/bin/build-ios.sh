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

#git clone https://github.com/phonegap/ios-deploy.git
#cd ios-deploy && xcodebuild && npm install --unsafe-perm=true --allow-root -g ios-deploy

# Be sure to use system python for ios-deploy/fruitstrap
PATH="/usr/bin/:${PATH}"
app_name=yourapp/_builds/${TOOLCHAIN}/Release-iphoneos/yourapp.app
bundle_id=com.example.integration.yourapp
ios-deploy --justlaunch --bundle ${app_name} --no-wifi


