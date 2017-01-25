# integration
Project integration and testing

Modified from the original https://github.com/forexample/ios-dynamic-framework specifically for resymbolification tests.

Apple technical doc on crash reports: https://developer.apple.com/library/content/technotes/tn2151/_index.html

https://developer.apple.com/library/content/technotes/tn2151/Art/tn2151_crash_flow.png

https://www.raywenderlich.com/23704/demystifying-ios-application-crash-logs

# Quick start:

## iOS

The end-to-end build is automated, but running currently requires manually adding the `mylib.framework` to the `yourapp` project before runnign.

1. Shell: cd integration/symbolification
2. Shell: export MY_IOS_IDENTITY="iPhone Developer: Your Name (XXXXXXXXXX)" # insert real values here
3. Shell: ./bin/build-ios.sh # this will an xcode project for `yourapp`
4. Xcode: File -> Add Files To Your App : `mylib/_framework/ios-10-1-dep-8-0-hid-sections/mylib.framework`
![xcode_add_files](https://cloud.githubusercontent.com/assets/554720/22299497/4e0e74c6-e2f2-11e6-903f-f9fac607b746.png)
5. Xcode: Target = yourapp General -> Embed Binaries -> + -> mylib.framework 
![xcode_embed_binaries](https://cloud.githubusercontent.com/assets/554720/22299399/f1f76300-e2f1-11e6-80b1-6f838caed224.png)
6. Xcode: Select iPhone device and run `yourapp` target


In Xcode 8.1 (at least) the crash logs can be viewed directly via: Xcode -> Window -> Devices -> Your iPhone -> View Device Logs -> This Device -> yourapp.

You can select and right-click a log, and a dialog will open asking you for:
* Delete log
* Export log
* Re-Symbolicate log

Choose to "Export Log" and provide a filename.  By default, this will generate a timestampled filename with a `.crash` extension that looks somethin glike this: `yourapp  1-16-17, 4-29 PM.crash`.


