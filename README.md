# integration
Project integration and testing

Lineage: https://github.com/forexample/ios-dynamic-framework sample by Ruslan Baratove.
Includes updates for resymbolification tasks.

# Quick start:

## Android

The end-to-end build + test should run automatically.  The `libmylib.so` shared library is installed in the `yourapp` install tree, which should be relocatable.  The app + lib are copied to the device `/data/local/tmp` where it is launch via `adb` commands to produce a stack trace that can be retrieved via `adb locat` and "resymbolificated" using `ndk-stack`.

1. Shell: `cd integration/symbolification` # cd to symbolification sub-project
2. Shell: `./bin/build-android.sh` # build libmylib.so and yourapp, install + launch w/ adb commands
3. Shell: `./bin/symbolicate-android.sh ` # resymbolicate

You will see `ndk-stack` output with and without symbols, and it should look something like this:

```
***************************
***** NO SYMBOLS **********
***************************
********** Crash dump: **********
Build fingerprint: 'samsung/heroqlteuc/heroqlteatt:6.0.1/MMB29M/G930AUCS2APE1:user/release-keys'
pid: 16581, tid: 16581, name: yourapp  >>> ./yourapp <<<
signal 11 (SIGSEGV), code 1 (SEGV_MAPERR), fault addr 0x0
Stack frame #00 pc 00008568  /data/local/tmp/work/libmylib.so (_ZN5mylib8crashsimEi+360)
Stack frame #01 pc 00003440  /data/local/tmp/work/yourapp
Stack frame #02 pc 00017449  /system/lib/libc.so (__libc_init+44)
Stack frame #03 pc 00003880  /data/local/tmp/work/yourapp
***************************
***** WITH SYMBOLS ********
***************************
********** Crash dump: **********
Build fingerprint: 'samsung/heroqlteuc/heroqlteatt:6.0.1/MMB29M/G930AUCS2APE1:user/release-keys'
pid: 16581, tid: 16581, name: yourapp  >>> ./yourapp <<<
signal 11 (SIGSEGV), code 1 (SEGV_MAPERR), fault addr 0x0
Stack frame #00 pc 00008568  /data/local/tmp/work/libmylib.so (_ZN5mylib8crashsimEi+360): Routine mylib::some_bad_func(int) at /tmp/integration/symbolification/mylib/mylib.cpp:15
Stack frame #01 pc 00003440  /data/local/tmp/work/yourapp
Stack frame #02 pc 00017449  /system/lib/libc.so (__libc_init+44)
Stack frame #03 pc 00003880  /data/local/tmp/work/yourapp
```

## iOS

Note: If the `*.crash` file is retrieved on the same machine used to build `libmylib.framework`, then Xcode magically resymbolicates the file for you.  It seems there is some behind the scenes book-keeping occurring in Xcode.  I was eventually able to test this end-to-end process properly by downloading the raw `*.crash` log file on a different machine, and then moving it back to the development machine.  This wasn't obvious at first, however CMake is stripping teh shared framework properly.

The end-to-end build + test should run automatically.  The `mylib.framework` framework is copied to`yourapp` in CMakeLists.txt and the final `yourapp.app` is launched on the device using `ios-deploy`. If you experience trouble, or the framework isn't inserted properly, follow the (optional) instructions below for adding the framework manually.  (I've added the manual instructions since the framework embedding is somewhat non-standarda (there is no `XCODE_ATTRIBUTE_*` property to control this is CMake, so I don't know how durable this is -- the manual process should always work).  For simplicity, all scripts below should be run from the top level symbolification directory as follows: `./bin/some-script-name.sh`.

TODO: Retrieve *.crash file programmatically?

1. Shell: `cd integration/symbolification` # cd to symbolification sub-project
2. Shell: `export MY_IOS_IDENTITY="iPhone Developer: Your Name (XXXXXXXXXX)"` # insert real values here
3. Shell: `(cd /tmp && git clone https://github.com/phonegap/ios-deploy.git && cd ios-deploy && xcodebuild && npm install --unsafe-perm=true --allow-root -g ios-deploy)` # install ios-deploy for automation
4. Shell: `./bin/build-ios.sh` # build mylib.framework, yourapp.app+mylib.framework and launch w/ ios-deploy
5. Xcode: Window -> Devices -> Your iPhone -> [View Device Logs] -> This Device -> `yourapp`
![xcode_device_log](https://cloud.githubusercontent.com/assets/554720/22301708/f58c3f10-e2f9-11e6-9192-fe049b2cce5a.png)
6. (Cont) right-click -> export -> save as: "your_app_log1". : # see not above about retrieving crash logs on a different machine
![xcode_device_log_export](https://cloud.githubusercontent.com/assets/554720/22302236/e368c6bc-e2fb-11e6-8a46-5660459864ce.png)
8. Shell: `./bin/symbolicate-ios.sh ${HOME}/Downloads/your_app_log1.crash  > /tmp/symbolicated.txt` # read this script for further details on the process

See: Following https://possiblemobile.com/2015/03/symbolicating-your-ios-crash-reports/ 

You are done.  Read the following sections as needed.

# Backup manual approach for embedding frameworks (currently performed by CMake and should not be required):

1. Xcode: File -> Add Files To Your App : `mylib/_framework/ios-10-1-dep-8-0-hid-sections/mylib.framework`
![xcode_add_files](https://cloud.githubusercontent.com/assets/554720/22299497/4e0e74c6-e2f2-11e6-903f-f9fac607b746.png)
2. Xcode: Target = yourapp General -> Embed Binaries -> + -> mylib.framework 
![xcode_embed_binaries](https://cloud.githubusercontent.com/assets/554720/22299399/f1f76300-e2f1-11e6-80b1-6f838caed224.png)

# Backup manual launch for created app (currently handled by ios-deploy)

1. Xcode: Select iPhone device and run `yourapp` target
![xcode_hello_from_yourapp](https://cloud.githubusercontent.com/assets/554720/22301327/acb57082-e2f8-11e6-98f6-012702652b1a.png)
2. Xcode: Stop the app.  You can run again from the installed icon (this seems to be required to actually creat the stack).

# Apple symbolification notes and documents

https://developer.apple.com/library/content/technotes/tn2151/_index.html
https://www.raywenderlich.com/23704/demystifying-ios-application-crash-logs
