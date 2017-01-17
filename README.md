# integration
Project integration and testing

Modified from the original https://github.com/forexample/ios-dynamic-framework specifically for resymbolification tests.

Apple technical doc on crash reports: https://developer.apple.com/library/content/technotes/tn2151/_index.html

https://developer.apple.com/library/content/technotes/tn2151/Art/tn2151_crash_flow.png

https://www.raywenderlich.com/23704/demystifying-ios-application-crash-logs

In Xcode 8.1 (at least) the crash logs can be viewed directly via: Xcode -> Window -> Devices -> Your iPhone -> View Device Logs -> This Device -> yourapp.

You can select and right-click a log, and a dialog will open asking you for:
* Delete log
* Export log
* Re-Symbolicate log

Choose to "Export Log" and provide a filename.  By default, this will generate a timestampled filename with a `.crash` extension that looks somethin glike this: `yourapp  1-16-17, 4-29 PM.crash`.


