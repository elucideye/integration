# integration
Project integration and testing

Modified from the original https://github.com/forexample/ios-dynamic-framework specifically for resymbolification tests.

Apple technical doc on crash reports: https://developer.apple.com/library/content/technotes/tn2151/_index.html

# Quick start:

## iOS

The end-to-end build + test should run automatically.  The `mylib.framework` framework is copied to`yourapp` in CMakeLists.txt and the final `yourapp.app` is launched on the device using `ios-deploy`. If you experience trouble or the framework isn't inserted properly, follow the instructions below for adding the framework manually.  For simplicity, all scripts below should be run form the top level symbolification directory using `./bin/scrip-name.sh`.

1. Shell: `cd integration/symbolification` # cd to symbolification sub-project
2. Shell: `export MY_IOS_IDENTITY="iPhone Developer: Your Name (XXXXXXXXXX)"` # insert real values here
3. Shell: `(cd /tmp && git clone https://github.com/phonegap/ios-deploy.git && cd ios-deploy && xcodebuild && npm install --unsafe-perm=true --allow-root -g ios-deploy)` # install ios-deploy for automation
4. Shell: `./bin/build-ios.sh` # build mylib.framework, yourapp.app+mylib.framework and launch w/ ios-deploy
5. Xcode: Window -> Devices -> Your iPhone -> [View Device Logs] -> This Device -> `yourapp`
![xcode_device_log](https://cloud.githubusercontent.com/assets/554720/22301708/f58c3f10-e2f9-11e6-9192-fe049b2cce5a.png)
6. (Cont) right-click -> export -> save as: "your_app_log1"
![xcode_device_log_export](https://cloud.githubusercontent.com/assets/554720/22302236/e368c6bc-e2fb-11e6-8a46-5660459864ce.png)
8. Shell: `./bin/symbolicate-ios.sh ${HOME}/Downloads/your_app_log1.crash  > /tmp/symbolicated.txt` # read this script for further details on the process

See: Following https://possiblemobile.com/2015/03/symbolicating-your-ios-crash-reports/ 

You are done.  Read the following sections as needed.

# Backup manual approach for embedding frameworks (currently performed by CMake and should not be required:)

1. Xcode: File -> Add Files To Your App : `mylib/_framework/ios-10-1-dep-8-0-hid-sections/mylib.framework`
![xcode_add_files](https://cloud.githubusercontent.com/assets/554720/22299497/4e0e74c6-e2f2-11e6-903f-f9fac607b746.png)
2. Xcode: Target = yourapp General -> Embed Binaries -> + -> mylib.framework 
![xcode_embed_binaries](https://cloud.githubusercontent.com/assets/554720/22299399/f1f76300-e2f1-11e6-80b1-6f838caed224.png)

# Backup manual launch for created app (currently handled by ios-deploy)

1. Xcode: Select iPhone device and run `yourapp` target
![xcode_hello_from_yourapp](https://cloud.githubusercontent.com/assets/554720/22301327/acb57082-e2f8-11e6-98f6-012702652b1a.png)
2. Xcode: Stop the app.  You can run again from the installed icon (this seems to be required to actually creat the stack).

# Apple symbolification notes and documents

https://developer.apple.com/library/content/technotes/tn2151/Art/tn2151_crash_flow.png

https://www.raywenderlich.com/23704/demystifying-ios-application-crash-logs
