#!/bin/bash

TOOLCHAIN=android-ndk-r10e-api-19-armeabi-v7a-neon-hid-sections

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
    polly.py --toolchain ${TOOLCHAIN} ${COMMANDS[*]} --install
)

( # Emulate 3rd-party consumer of shared library:
    cd yourapp
    polly.py --toolchain ${TOOLCHAIN} ${COMMANDS[*]} --fwd "MYLIB_DIR=${MYLIB_DIR}" --install
)

adb shell "mkdir -p /data/local/tmp/work"
adb push "yourapp/_install/${TOOLCHAIN}/bin/yourapp" /data/local/tmp/work
adb push "yourapp/_install/${TOOLCHAIN}/lib/libmylib.so" /data/local/tmp/work
adb shell "cd /data/local/tmp/work && chmod 755 yourapp && export LD_LIBRARY_PATH=\${PWD} && ./yourapp"
