# Firebase Cloud Messaging for Flutter

[![pub package](https://img.shields.io/pub/v/firebase_messaging.svg)](https://pub.dev/packages/firebase_messaging)

A Flutter plugin to use the [Firebase Cloud Messaging (FCM) API](https://firebase.google.com/docs/cloud-messaging/).

With this plugin, your Flutter app can receive and process push notifications as well as data messages on Android and iOS. Read Firebase's [About FCM Messages](https://firebase.google.com/docs/cloud-messaging/concept-options) to learn more about the differences between notification messages and data messages.

For Flutter plugins for other Firebase products, see [README.md](https://github.com/FirebaseExtended/flutterfire/blob/master/README.md).

## Usage
To use this plugin, add `firebase_messaging` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

## Getting Started

Check out the `example` directory for a sample app using Firebase Cloud Messaging.

### Android Integration

To integrate your plugin into the Android part of your app, follow these steps:

1. Using the [Firebase Console](https://console.firebase.google.com/) add an Android app to your project: Follow the assistant, download the generated `google-services.json` file and place it inside `android/app`.

2. Add the classpath to the `[project]/android/build.gradle` file.
```
dependencies {
  // Example existing classpath
  classpath 'com.android.tools.build:gradle:3.5.3'
  // Add the google services classpath
  classpath 'com.google.gms:google-services:4.3.2'
}
```
3. Add the apply plugin to the `[project]/android/app/build.gradle` file.
```
// ADD THIS AT THE BOTTOM
apply plugin: 'com.google.gms.google-services'
```

Note: If this section is not completed you will get an error like this:
```
java.lang.IllegalStateException:
Default FirebaseApp is not initialized in this process [package name].
Make sure to call FirebaseApp.initializeApp(Context) first.
```

Note: When you are debugging on Android, use a device or AVD with Google Play services. Otherwise you will not be able to authenticate.

4. (optional, but recommended) If want to be notified in your app (via `onResume` and `onLaunch`, see below) when the user clicks on a notification in the system tray include the following `intent-filter` within the `<activity>` tag of your `android/app/src/main/AndroidManifest.xml`:
  ```xml
  <intent-filter>
      <action android:name="FLUTTER_NOTIFICATION_CLICK" />
      <category android:name="android.intent.category.DEFAULT" />
  </intent-filter>
  ```

### iOS Integration

To integrate your plugin into the iOS part of your app, follow these steps:

1. Generate the certificates required by Apple for receiving push notifications following [this guide](https://firebase.google.com/docs/cloud-messaging/ios/certs) in the Firebase docs. You can skip the section titled "Create the Provisioning Profile".

1. Using the [Firebase Console](https://console.firebase.google.com/) add an iOS app to your project: Follow the assistant, download the generated `GoogleService-Info.plist` file, open `ios/Runner.xcworkspace` with Xcode, and within Xcode place the file inside `ios/Runner`. **Don't** follow the steps named "Add Firebase SDK" and "Add initialization code" in the Firebase assistant.

1. In Xcode, select `Runner` in the Project Navigator. In the Capabilities Tab turn on `Push Notifications` and `Background Modes`, and enable `Background fetch` and `Remote notifications` under `Background Modes`.

1. Follow the steps in the "[Upload your APNs certificate](https://firebase.google.com/docs/cloud-messaging/ios/client#upload_your_apns_certificate)" section of the Firebase docs.

1. If you need to disable the method swizzling done by the FCM iOS SDK (e.g. so that you can use this plugin with other notification plugins) then add the following to your application's `Info.plist` file.

```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

After that, add the following lines to the `(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions`
method in the `AppDelegate.m`/`AppDelegate.swift` of your iOS project.

Objective-C:
```objectivec
if (@available(iOS 10.0, *)) {
  [UNUserNotificationCenter currentNotificationCenter].delegate = (id<UNUserNotificationCenterDelegate>) self;
}
```

Swift:
```swift
if #available(iOS 10.0, *) {
  UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
}
```

### Handle background messages (Optional)

#### Android configuration
>Background message handling is intended to be performed quickly. Do not perform
long running tasks as they may not be allowed to finish by the Android system.
See [Background Execution Limits](https://developer.android.com/about/versions/oreo/background)
for more.

By default background messaging is not enabled. To handle messages in the background:

1. Add the `com.google.firebase:firebase-messaging` dependency in your app-level `build.gradle` file that is typically located at `<app-name>/android/app/build.gradle`.

   ```gradle
   dependencies {
     // ...
   
     implementation 'com.google.firebase:firebase-messaging:<latest_version>'
   }
   ```
   
   Note: you can find out what the latest version of the plugin is [here ("Cloud Messaging")](https://firebase.google.com/support/release-notes/android#latest_sdk_versions).

1. Add an `Application.java` class to your app in the same directory as your `MainActivity.java`. This is typically found in `<app-name>/android/app/src/main/java/<app-organization-path>/`.

   ```java
   package io.flutter.plugins.firebasemessagingexample;
   
   import io.flutter.app.FlutterApplication;
   import io.flutter.plugin.common.PluginRegistry;
   import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
   import io.flutter.plugins.GeneratedPluginRegistrant;
   import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService;
   
   public class Application extends FlutterApplication implements PluginRegistrantCallback {
     @Override
     public void onCreate() {
       super.onCreate();
       FlutterFirebaseMessagingService.setPluginRegistrant(this);
     }
   
     @Override
     public void registerWith(PluginRegistry registry) {
       GeneratedPluginRegistrant.registerWith(registry);
     }
   }
   ```

1. In `Application.java`, make sure to change `package io.flutter.plugins.firebasemessagingexample;` to your package's identifier. Your package's identifier should be something like `com.domain.myapplication`.

   ```java
   package com.domain.myapplication;
   ```

1. Set name property of application in `AndroidManifest.xml`. This is typically found in `<app-name>/android/app/src/main/`.

   ```xml
   <application android:name=".Application" ...>
   ```

#### iOS configuration (Swift)
1. In the top of `AppDelegate.swift`, add the import of firebase_messaging:
   
   ```swift
    import firebase_messaging
   ```

1. Then add the following code to `AppDelegate.swift` (E.g. last in the function `application` right before the return statement)):

   ```swift
    FLTFirebaseMessagingPlugin.setPluginRegistrantCallback({ (registry: FlutterPluginRegistry) -> Void in
      GeneratedPluginRegistrant.register(with: registry);
    });
   ```

#### Usage in the common Dart code
1. Define a **TOP-LEVEL** or **STATIC** function to handle background messages

   ```dart
   Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
     if (message.containsKey('data')) {
       // Handle data message
       final dynamic data = message['data'];
     }
   
     if (message.containsKey('notification')) {
       // Handle notification message
       final dynamic notification = message['notification'];
     }
   
     // Or do other work.
   }
   ```

   Note: the protocol of `data` and `notification` are in line with the
   fields defined by a [RemoteMessage](https://firebase.google.com/docs/reference/android/com/google/firebase/messaging/RemoteMessage). 

1. Set `onBackgroundMessage` handler when calling `configure`

   ```dart
   _firebaseMessaging.configure(
         onMessage: (Map<String, dynamic> message) async {
           print("onMessage: $message");
           _showItemDialog(message);
         },
         onBackgroundMessage: myBackgroundMessageHandler,
         onLaunch: (Map<String, dynamic> message) async {
           print("onLaunch: $message");
           _navigateToItemDetail(message);
         },
         onResume: (Map<String, dynamic> message) async {
           print("onResume: $message");
           _navigateToItemDetail(message);
         },
       );
   ```

   Note: `configure` should be called early in the lifecycle of your application
   so that it can be ready to receive messages as early as possible. See the
   [example app](https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_messaging/example) for a demonstration.


### Dart/Flutter Integration

From your Dart code, you need to import the plugin and instantiate it:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
```

Next, you should probably request permissions for receiving Push Notifications. For this, call `_firebaseMessaging.requestNotificationPermissions()`. This will bring up a permissions dialog for the user to confirm on iOS. It's a no-op on Android. Last, but not least, register `onMessage`, `onResume`, and `onLaunch` callbacks via `_firebaseMessaging.configure()` to listen for incoming messages (see table below for more information).

## Receiving Messages

Messages are sent to your Flutter app via the `onMessage`, `onLaunch`, `onResume` and `onBackgroundMessage` callbacks that you configured with the plugin during setup. Here is how different message types are delivered on the supported platforms:

|                             | App in Foreground | App in Background                                                                                                                                                   | App Terminated                                                                                                                                                      |
| --------------------------: | ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Notification on Android** | `onMessage`       | Notification is delivered to system tray. When the user clicks on it to open app `onResume` fires if `click_action: FLUTTER_NOTIFICATION_CLICK` is set (see below). | Notification is delivered to system tray. When the user clicks on it to open app `onLaunch` fires if `click_action: FLUTTER_NOTIFICATION_CLICK` is set (see below). |
|     **Notification on iOS** | `onMessage`       | Notification is delivered to system tray. When the user clicks on it to open app `onResume` fires.                                                                  | Notification is delivered to system tray. When the user clicks on it to open app `onLaunch` fires.                                                                  |
| **Data Message on Android** | `onMessage`       | `onMessage` while app stays in the background.                                                                                                                      | *not supported by plugin, message is lost*                                                                                                                          |
|     **Data Message on iOS** | `onMessage`       | Message is delivered to `onBackgroundMessage`. This is the case both when app is running in background and the system has suspended the app.                        | When app is force-quit by the user the message is not handled.                                                                                                      |

Additional reading: Firebase's [About FCM Messages](https://firebase.google.com/docs/cloud-messaging/concept-options).

## Notification messages with additional data
It is possible to include additional data in notification messages by adding them to the `"data"`-field of the message.

On Android, the message contains an additional field `data` containing the data. On iOS, the data is directly appended to the message and the additional `data`-field is omitted.

To receive the data on both platforms:

````dart
Future<void> _handleNotification (Map<dynamic, dynamic> message, bool dialog) async {
    var data = message['data'] ?? message;
    String expectedAttribute = data['expectedAttribute'];
    /// [...]
}
````

## Sending Messages
Refer to the [Firebase documentation](https://firebase.google.com/docs/cloud-messaging/) about FCM for all the details about sending messages to your app. When sending a notification message to an Android device, you need to make sure to set the `click_action` property of the message to `FLUTTER_NOTIFICATION_CLICK`. Otherwise the plugin will be unable to deliver the notification to your app when the users clicks on it in the system tray.

For testing purposes, the simplest way to send a notification is via the [Firebase Console](https://firebase.google.com/docs/cloud-messaging/send-with-console). Make sure to include `click_action: FLUTTER_NOTIFICATION_CLICK` as a "Custom data" key-value-pair (under "Advanced options") when targeting an Android device. The Firebase Console does not support sending data messages.

Alternatively, a notification or data message can be sent from a terminal:

```shell
DATA='{"notification": {"body": "this is a body","title": "this is a title"}, "priority": "high", "data": {"click_action": "FLUTTER_NOTIFICATION_CLICK", "id": "1", "status": "done"}, "to": "<FCM TOKEN>"}'
curl https://fcm.googleapis.com/fcm/send -H "Content-Type:application/json" -X POST -d "$DATA" -H "Authorization: key=<FCM SERVER KEY>"
```

Remove the `notification` property in `DATA` to send a data message.

You could also test this from within Flutter using the [http](https://pub.dev/packages/http) package:

```dart
// Replace with server token from firebase console settings.
final String serverToken = '<Server-Token>';
final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

Future<Map<String, dynamic>> sendAndRetrieveMessage() async {
  await firebaseMessaging.requestNotificationPermissions(
    const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: false),
  );

  await http.post(
    'https://fcm.googleapis.com/fcm/send',
     headers: <String, String>{
       'Content-Type': 'application/json',
       'Authorization': 'key=$serverToken',
     },
     body: jsonEncode(
     <String, dynamic>{
       'notification': <String, dynamic>{
         'body': 'this is a body',
         'title': 'this is a title'
       },
       'priority': 'high',
       'data': <String, dynamic>{
         'click_action': 'FLUTTER_NOTIFICATION_CLICK',
         'id': '1',
         'status': 'done'
       },
       'to': await firebaseMessaging.getToken(),
     },
    ),
  );

  final Completer<Map<String, dynamic>> completer =
     Completer<Map<String, dynamic>>();

  firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) async {
      completer.complete(message);
    },
  );

  return completer.future;
}
```

## Issues and feedback

Please file FlutterFire specific issues, bugs, or feature requests in our [issue tracker](https://github.com/FirebaseExtended/flutterfire/issues/new).

Plugin issues that are not specific to Flutterfire can be filed in the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).

To contribute a change to this plugin,
please review our [contribution guide](https://github.com/FirebaseExtended/flutterfire/blob/master/CONTRIBUTING.md)
and open a [pull request](https://github.com/FirebaseExtended/flutterfire/pulls).
