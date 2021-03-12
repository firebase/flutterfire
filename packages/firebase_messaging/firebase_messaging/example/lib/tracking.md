# Work on demo and fix for Issue #4949

## Sucessful execution of example, unchanged.... (NB: unsound null safety)

```
C:\Users\nigel\VSCprojects\flutterfire\packages\firebase_messaging\firebase_messaging\example>flutter run -d emulator
Using hardware rendering with device Android SDK built for x86. If you notice graphics artifacts, consider enabling
software rendering with "--enable-software-rendering".
Launching lib\main.dart on Android SDK built for x86 in debug mode...
Running Gradle task 'assembleDebug'...
Running Gradle task 'assembleDebug'... Done                        31.1s
√ Built build\app\outputs\flutter-apk\app-debug.apk.
I/flutter ( 6204): FCM Token: eGQ8xYMeSIGxCWN04R5LuY:APA91bH7PC_3idAosudid63d6hs2f14Li4EkXG010_ilsjBjHLqR1hWbD45-qUrH3vH0h6mwva5DJCTvQvtAPd8kq_UPBb_MXR-G9VGTPjjm_zwR92NKZTIWhyFhvBHfillgF3Tc2yzW
Activating Dart DevTools...                                        10.1s
Syncing files to device Android SDK built for x86...               145ms

Flutter run key commands.
r Hot reload.
R Hot restart.
h Repeat this help message.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).
An Observatory debugger and profiler on Android SDK built for x86 is available at: http://127.0.0.1:16774/MpmvJtIRNPE=/

Flutter DevTools, a Flutter debugger and profiler, on Android SDK built for x86 is available at:
http://127.0.0.1:9102?uri=http%3A%2F%2F127.0.0.1%3A16774%2FMpmvJtIRNPE%3D%2F

Running with unsound null safety
For more information see https://dart.dev/null-safety/unsound-null-safety
D/FLTFireMsgReceiver( 6204): broadcast received for message
W/FirebaseMessaging( 6204): Unable to log event: analytics library is missing
W/FirebaseMessaging( 6204): Unable to log event: analytics library is missing
I/flutter ( 6204): FCM request for device sent!

Application finished.
```

## Convert example to sound null safety

Minimal changes to make it compile under null-safety. Some of the updates may be incorrect, but they are in any case not involved in the issue at stake here.
