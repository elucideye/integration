#!/bin/bash

# Includes
. bin/android-toolchain.sh

MYLIB_DIR="${PWD}/mylib/_install/${TOOLCHAIN}/lib/cmake/myLib"

ls ${MYLIB_DIR}

COMMANDS=(
    "--config=Release "
    "--verbose "
    "--jobs 8 "
    "--reconfig "
    "--clear "
)

( # Build shared library:
    cd mylib
    polly.py --toolchain ${TOOLCHAIN} ${COMMANDS[*]} --strip
)

( # Emulate 3rd-party consumer of shared library:
    cd yourapp
    polly.py --toolchain ${TOOLCHAIN} ${COMMANDS[*]} --fwd "MYLIB_DIR=${MYLIB_DIR}" --strip
)

########################
### Check stripping
########################
APP_PATH=yourapp/_install/${TOOLCHAIN}/bin/yourapp
LIB_PATH=yourapp/_install/${TOOLCHAIN}/lib/libmylib.so
TOOL=arm-linux-androideabi-g++
TOOL=arm-linux-androideabi-gcc-nm
ANDROID_NM=${ANDROID_NDK_r10e}/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64/bin/${TOOL}
${ANDROID_NM} -g ${LIB_PATH}

adb shell "mkdir -p /data/local/tmp/work"
adb push "${APP_PATH}" /data/local/tmp/work
adb push "${LIB_PATH}" /data/local/tmp/work
adb logcat -c
adb shell "cd /data/local/tmp/work && chmod 755 yourapp && export LD_LIBRARY_PATH=\${PWD} && ./yourapp"
mkdir -p _sandbox
adb logcat -d > _sandbox/android_log.txt # dump and quit

