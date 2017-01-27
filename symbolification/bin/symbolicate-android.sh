#/bin/bash

. bin/android-toolchain.sh

if [ -z "${ANDROID_NDK_r10e}" ]; then
    2>&1 echo "Must have ANDROID_NDK_r10e installed/set"
    exit 1
fi

######################################################################################
# tree mylib/_install/android-ndk-r10e-api-19-armeabi-v7a-neon-hid-sections/.build-id/
#
# mylib/_install/android-ndk-r10e-api-19-armeabi-v7a-neon-hid-sections/.build-id/
# └── ab
#     └── cdef1234.debug
######################################################################################



########################
### Check stripping
########################
APP_PATH=yourapp/_install/${TOOLCHAIN}/bin/yourapp
LIB_PATH=yourapp/_install/${TOOLCHAIN}/lib/libmylib.so
NDK_NM=${ANDROID_NDK_r10e}/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64/bin/arm-linux-androideabi-gcc-nm
NDK_STACK=${ANDROID_NDK_r10e}/ndk-stack

${NDK_NM} -g ${LIB_PATH} # should report "no symbols"

echo "***************************"
echo "***** NO SYMBOLS **********"
echo "***************************"

${NDK_STACK} -sym mylib/_install/${TOOLCHAIN}/libs -dump _sandbox/android_log.txt

echo "***************************"
echo "***** WITH SYMBOLS ********"
echo "***************************"

# Resymbolicate using full symbol versions:
# Android needs original lib name:
(cd  mylib/_install/${TOOLCHAIN}/.build-id/ab/ && ln -s cdef1234.debug libmylib.so) 
${NDK_STACK} -sym mylib/_install/${TOOLCHAIN}/.build-id/ab/ -dump _sandbox/android_log.txt
