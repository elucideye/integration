#!/bin/bash

TOOLCHAIN=android-ndk-r10e-api-19-armeabi-v7a-neon-hid-sections

( # Build shared library:
    cd MyLib
    polly.py --toolchain ${TOOLCHAIN} ${COMMANDS[*]} --reconfig --clear --config=Release --verbose --install
)

MY_DIR=${PWD}/MyLib/_install/android-ndk-r10e-api-19-armeabi-v7a-neon-hid-sections/lib/cmake/MyLib

( # Emulate 3rd-party consumer of shared library:
    cd MyApp
    polly.py --toolchain ${TOOLCHAIN} ${COMMANDS[*]} --reconfig --clear --config=Release --verbose --fwd "MY_DIR=${MY_DIR}"
)
