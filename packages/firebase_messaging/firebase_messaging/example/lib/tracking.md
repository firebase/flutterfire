# Work on demo and fix for Issue #4949

## Sucessful execution of example, unchanged.... (NB: unsound null safety)

``` txt
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

Minimal changes to make it compile under null-safety. Some of the updates may be disputable, but they are in any case not involved in the issue at stake here.

## Failed execution of example when running in sound null safety

Failed because, after tapping FAB, the "Message Stream" card continues to show no message received.

Of note: no exception raised to application, the FCM is silently discarded

``` txt
C:\Users\nigel\VSCprojects\flutterfire\packages\firebase_messaging\firebase_messaging\example>flutter run
Using hardware rendering with device Android SDK built for x86. If you notice graphics artifacts, consider enabling software rendering with "--enable-software-rendering".
Launching lib\main.dart on Android SDK built for x86 in debug mode...
Note: C:\Users\nigel\AppData\Roaming\Pub\Cache\hosted\pub.dartlang.org\flutter_local_notifications-5.0.0-nullsafety.1\android\src\main\java\com\dexterous\flutterlocalnotifications\FlutterLocalNotificationsPlugin.java uses or overrides a deprecated API.
Note: Recompile with -Xlint:deprecation for details.
Running Gradle task 'assembleDebug'...
Running Gradle task 'assembleDebug'... Done                        41.6s
√ Built build\app\outputs\flutter-apk\app-debug.apk.
Installing build\app\outputs\flutter-apk\app.apk...              1,686ms
Syncing files to device Android SDK built for x86...               219ms

Flutter run key commands.
r Hot reload.
R Hot restart.
h Repeat this help message.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).
An Observatory debugger and profiler on Android SDK built for x86 is available at: http://127.0.0.1:24188/Ml5EjtHjkzw=/

Flutter DevTools, a Flutter debugger and profiler, on Android SDK built for x86 is available at: http://127.0.0.1:9103?uri=http%3A%2F%2F127.0.0.1%3A24188%2FMl5EjtHjkzw%3D%2F

 Running with sound null safety
I/FLTFireMsgService( 6989): FlutterFirebaseMessagingBackgroundService started!
I/flutter ( 6989): FCM Token: eGQ8xYMeSIGxCWN04R5LuY:APA91bH7PC_3idAosudid63d6hs2f14Li4EkXG010_ilsjBjHLqR1hWbD45-qUrH3vH0h6mwva5DJCTvQvtAPd8kq_UPBb_MXR-G9VGTPjjm_zwR92NKZTIWhyFhvBHfillgF3Tc2yzW
D/FLTFireMsgReceiver( 6989): broadcast received for message
W/FirebaseMessaging( 6989): Unable to log event: analytics library is missing
W/FirebaseMessaging( 6989): Unable to log event: analytics library is missing
I/flutter ( 6989): FCM request for device sent!

Application finished.
```

## Apply proposed correction to rempte_message.dart

This reapplies the '?? false' to '.mutableContent' & '.contentAvailable' which have become type boolean in NNBD and cannot be set to null in the case where these items are not included in the message.

## Execute the example once again, still under null safety

Example once again correctls shows receipt of message in Message Stream Pane, but now running under sound null safety

```
C:\Users\nigel\VSCprojects\flutterfire\packages\firebase_messaging\firebase_messaging\example>flutter run
Using hardware rendering with device Android SDK built for x86. If you notice graphics artifacts, consider enabling software rendering with "--enable-software-rendering".
Launching lib\main.dart on Android SDK built for x86 in debug mode...
Running Gradle task 'assembleDebug'...
Running Gradle task 'assembleDebug'... Done                        24.9s
√ Built build\app\outputs\flutter-apk\app-debug.apk.
Syncing files to device Android SDK built for x86...               120ms

Flutter run key commands.
r Hot reload.
R Hot restart.
h Repeat this help message.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).
An Observatory debugger and profiler on Android SDK built for x86 is available at: http://127.0.0.1:28396/WlI-YO7N0wY=/

Flutter DevTools, a Flutter debugger and profiler, on Android SDK built for x86 is available at: http://127.0.0.1:9106?uri=http%3A%2F%2F127.0.0.1%3A28396%2FWlI-YO7N0wY%3D%2F

 Running with sound null safety
I/flutter ( 8022): FCM Token: eGQ8xYMeSIGxCWN04R5LuY:APA91bH7PC_3idAosudid63d6hs2f14Li4EkXG010_ilsjBjHLqR1hWbD45-qUrH3vH0h6mwva5DJCTvQvtAPd8kq_UPBb_MXR-G9VGTPjjm_zwR92NKZTIWhyFhvBHfillgF3Tc2yzW
D/FLTFireMsgReceiver( 8022): broadcast received for message
W/FirebaseMessaging( 8022): Unable to log event: analytics library is missing
W/FirebaseMessaging( 8022): Unable to log event: analytics library is missing
I/flutter ( 8022): FCM request for device sent!

Application finished.
```
