# integration
Project integration and testing

Modified from the original https://github.com/forexample/ios-dynamic-framework specifically for resymbolification tests.

Apple technical doc on crash reports: https://developer.apple.com/library/content/technotes/tn2151/_index.html

https://developer.apple.com/library/content/technotes/tn2151/Art/tn2151_crash_flow.png

https://www.raywenderlich.com/23704/demystifying-ios-application-crash-logs

# Quick start:

## iOS

The end-to-end build is automated, but running currently requires manually adding the `mylib.framework` to the `yourapp` project before running.

1. Shell: cd integration/symbolification
2. Shell: export MY_IOS_IDENTITY="iPhone Developer: Your Name (XXXXXXXXXX)" # insert real values here
3. Shell: ./bin/build-ios.sh # this will an xcode project for `yourapp`
4. Xcode: Select iPhone device and run `yourapp` target
![xcode_hello_from_yourapp](https://cloud.githubusercontent.com/assets/554720/22301327/acb57082-e2f8-11e6-98f6-012702652b1a.png)
5. Xcode: Stop the app.  You can run again from the installed icon.
6. Xcode: Window -> Devices -> Your iPhone -> [View Device Logs] -> This Device -> `yourapp`
![xcode_device_log](https://cloud.githubusercontent.com/assets/554720/22301708/f58c3f10-e2f9-11e6-9192-fe049b2cce5a.png)
7. (Cont) right-click -> export -> save as: "your_app_log1"
![xcode_device_log_export](https://cloud.githubusercontent.com/assets/554720/22302236/e368c6bc-e2fb-11e6-8a46-5660459864ce.png)
8. Shell: `ls ~/Downloads/your_app_log1.crash`
9. Locate `symbolicatecrash` app: `/Applications/develop/ide/xcode/8.1/Xcode.app/Contents/SharedFrameworks/DVTFoundation.framework/Versions/A/Resources/symbolicatecrash` and set path accordingly : `export PATH="${PATH}:/Applications/develop/ide/xcode/8.1/Xcode.app/Contents/SharedFrameworks/DVTFoundation.framework/Versions/A/Resources/"` and `export DEVELOPER_DIR=/Applications/develop/ide/xcode/8.1/Xcode.app/Contents/Developer`
10. Place your .crash, and .dSYM files in the same directory and run `symbolicatecrash`: `cd /tmp/sandbox && tar zcvf staging.tgz -C ${INTEGRATION}/symbolification/mylib/_builds/ios-10-1-dep-8-0-hid-sections/Release-iphoneos/ libmylib.dylib.dSYM && tar zxvf staging.tgz && cp ${HOME}/Downloads/your_app_log1.crash . && symbolicatecrash your_app_log1.crash > your_app_log1.txt`

See: Following https://possiblemobile.com/2015/03/symbolicating-your-ios-crash-reports/ 

Backup manual approach for embedding frameworks (currently performed by CMake and should not be required:)
1. Xcode: File -> Add Files To Your App : `mylib/_framework/ios-10-1-dep-8-0-hid-sections/mylib.framework`
![xcode_add_files](https://cloud.githubusercontent.com/assets/554720/22299497/4e0e74c6-e2f2-11e6-903f-f9fac607b746.png)
2. Xcode: Target = yourapp General -> Embed Binaries -> + -> mylib.framework 
![xcode_embed_binaries](https://cloud.githubusercontent.com/assets/554720/22299399/f1f76300-e2f1-11e6-80b1-6f838caed224.png)
