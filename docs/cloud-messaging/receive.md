Project: /docs/cloud-messaging/_project.yaml
Book: /docs/_book.yaml
page_type: guide

{% include "_shared/apis/console/_local_variables.html" %}
{% include "_local_variables.html" %}
{% include "docs/cloud-messaging/_local_variables.html" %}
{% include "docs/android/_local_variables.html" %}

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Receive messages in a Flutter app

Depending on a device's state, incoming messages are handled differently. To
understand these scenarios and how to integrate FCM into your own application, it
is first important to establish the various states a device can be in:

| State          | Description
| -------------- | -----------
| **Foreground** | When the application is open, in view and in use.
| **Background** | When the application is open, but in the background (minimized).
:                : This typically occurs when the user has pressed the "home" button
:                : on the device, has switched to another app using the app switcher,
:                : or has the application open in a different tab (web).
| **Terminated** | When the device is locked or the application is not running.

There are a few preconditions which must be met before the application can
receive message payloads via FCM:

- The application must have opened at least once (to allow for registration with FCM).
- On iOS, if the user swipes away the application from the app switcher, it must be manually reopened for background messages to start working again.
- On Android, if the user force-quits the app from device settings, it must be manually reopened for messages to start working.
- On web, you must have requested a token (using `getToken()`) with your web push certificate.

## Request permission to receive messages (Apple and Web)

On iOS, macOS and web, before FCM payloads can be received on your device, you must first ask the user's permission.

The `firebase_messaging` package provides a simple API for requesting permission via the [`requestPermission`](https://pub.dev/documentation/firebase_messaging/latest/firebase_messaging/FirebaseMessaging/requestPermission.html) method.
This API accepts a number of named arguments which define the type of permissions you'd like to request, such as whether
messaging containing notification payloads can trigger a sound or read out messages via Siri. By default,
the method requests sensible default permissions. The reference API provides full documentation on what each permission is for.

To get started, call the method from your application (on iOS a native modal will be displayed, on web
the browser's native API flow will be triggered):

```dart
FirebaseMessaging messaging = FirebaseMessaging.instance;

NotificationSettings settings = await messaging.requestPermission(
  alert: true,
  announcement: false,
  badge: true,
  carPlay: false,
  criticalAlert: false,
  provisional: false,
  sound: true,
);

print('User granted permission: ${settings.authorizationStatus}');
```

The `authorizationStatus` property of the `NotificationSettings` object returned from
the request can be used to determine the user's overall decision:

- `authorized`: The user granted permission.
- `denied`: The user denied permission.
- `notDetermined`: The user has not yet chosen whether to grant permission.
- `provisional`: The user granted provisional permission

Note: On Android `authorizationStatus` will return `authorized` if the user has not disabled notifications for the app via the operating systems settings.

The other properties on `NotificationSettings` return whether a specific permission is enabled, disabled or not supported on the current
device.

Once permission has been granted and the different types of device state have been understood, your application can now start to handle the incoming
FCM payloads.

## Message handling

Based on your application's current state, incoming payloads of different
[message types](/docs/cloud-messaging/concept-options#notifications_and_data_messages)
require different implementations to handle them:

### Foreground messages

To handle messages while your application is in the foreground, listen to the `onMessage` stream.

```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  print('Got a message whilst in the foreground!');
  print('Message data: ${message.data}');

  if (message.notification != null) {
    print('Message also contained a notification: ${message.notification}');
  }
});
```

The stream contains a `RemoteMessage`, detailing
various information about the payload, such as where it was from, the unique ID, sent time, whether it contained
a notification and more. Since the message was retrieved whilst your application is in the foreground, you can directly access your Flutter
application's state and context.

#### Foreground and Notification messages

Notification messages which arrive while the application is in the foreground will not display a visible notification by default, on both
Android and iOS. It is, however, possible to override this behavior:

- On Android, you must create a "High Priority" notification channel.
- On iOS, you can update the presentation options for the application.


### Background messages

The process of handling background messages is different on native (Android and
Apple) and web based platforms.

#### Apple platforms and Android

Handle background messages by registering a `onBackgroundMessage` handler. When messages are received, an
isolate is spawned (Android only, iOS/macOS does not require a separate isolate) allowing you to handle messages even when your application is not running.

There are a few things to keep in mind about your background message handler:

1. It must not be an anonymous function.
2. It must be a top-level function (e.g. not a class method which requires initialization).
3. It must be annotated with `@pragma('vm:entry-point')` right above the function declaration (otherwise it may be removed during tree shaking for release mode).

Note: The `@pragma('vm:entry-point')` annotation is a requirement when using Flutter version `3.3.0` or higher.

```dart
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}
```

Since the handler runs in its own isolate outside your applications context, it is not possible to update
application state or execute any UI impacting logic. You can, however, perform logic such as HTTP requests, perform IO operations
(e.g. updating local storage), communicate with other plugins etc.

It is also recommended to complete your logic as soon as possible. Running long, intensive tasks impacts device performance
and may cause the OS to terminate the process. If tasks run for longer than 30 seconds, the device may automatically kill the process.

#### Web

On the Web, write a JavaScript [Service Worker](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API) which runs in the background.
Use the service worker to handle background messages.

To get started, create a new file in the your `web` directory, and call it `firebase-messaging-sw.js`:

```js title=web/firebase-messaging-sw.js
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "...",
  authDomain: "...",
  databaseURL: "...",
  projectId: "...",
  storageBucket: "...",
  messagingSenderId: "...",
  appId: "...",
});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});
```

The file must import both the app and messaging SDKs, initialize Firebase and expose the `messaging` variable.

Next, the worker must be registered. Within the entry file, **after** the `main.dart.js` file has loaded, register your worker:

```js
<html>
<body>
  ...
  <script src="main.dart.js" type="application/javascript"></script>
  <script>
       if ('serviceWorker' in navigator) {
          // Service workers are supported. Use them.
          window.addEventListener('load', function () {
            // ADD THIS LINE
            navigator.serviceWorker.register('/firebase-messaging-sw.js');

            // Wait for registration to finish before dropping the <script> tag.
            // Otherwise, the browser will load the script multiple times,
            // potentially different versions.
            var serviceWorkerUrl = 'flutter_service_worker.js?v=' + serviceWorkerVersion;

            //  ...
          });
      }
  </script>
```

Next restart your Flutter application. The worker will be registered and any background messages will be handled via this file.

### Handling Interaction

Since notifications are a visible cue, it is common for users to interact with them (by pressing). The default behavior on both Android and iOS is to open the
application. If the application is terminated it will be started; if it is in the background it will be brought to the foreground.

Depending on the content of a notification, you may wish to handle the user's interaction when the application opens. For example, if a new chat message is sent via
a notification and the user presses it, you may want to open the specific conversation when the application opens.

The `firebase-messaging` package provides two ways to handle this interaction:

- `getInitialMessage()`: If the application is opened from a terminated state a `Future` containing a `RemoteMessage` will be returned. Once consumed, the `RemoteMessage` will be removed.
- `onMessageOpenedApp`: A `Stream` which posts a `RemoteMessage` when the application is opened from a background state.

It is recommended that both scenarios are handled to ensure a smooth UX for your users. The code example below outlines how this can be achieved:

```dart
class Application extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Application();
}

class _Application extends State<Application> {
  // It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data['type'] == 'chat') {
      Navigator.pushNamed(context, '/chat',
        arguments: ChatArguments(message),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    // Run code required to handle interacted messages in an async function
    // as initState() must not be async
    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Text("...");
  }
}
```

How you handle interaction depends on your application setup. The above example shows a basic illustration using a StatefulWidget.

## Localize Messages

You can send localized strings in two different ways:

* Store the preferred language of each of your users in your server and send customized notifications for each language
* Embed localized strings in your app and make use of the operating system's native locale settings

Here's how to use the second method:

### Android

1. Specify your default-language messages in `resources/values/strings.xml`:

   ```xml
   <string name="notification_title">Hello world</string>
   <string name="notification_message">This is a message</string>
   ```

2. Specify the translated messages in the <code>values-<var>language</var></code> directory. For example, specify French messages in `resources/values-fr/strings.xml`:

   ```xml
   <string name="notification_title">Bonjour le monde</string>
   <string name="notification_message">C'est un message</string>
   ```

3. In the server payload, instead of using `title`, `message`, and `body`  keys, use `title_loc_key` and `body_loc_key` for your localized message, and set them to the `name` attribute of the message you want to display.

   The message payload would look like this:

   ```json
   {
     "data": {
       "title_loc_key": "notification_title",
       "body_loc_key": "notification_message"
     },
   }
   ```


### iOS

1. Specify your default-language messages in `Base.lproj/Localizable.strings`:

   ```
   "NOTIFICATION_TITLE" = "Hello World";
   "NOTIFICATION_MESSAGE" = "This is a message";
   ```

2. Specify the translated messages in the <code><var>language</var>.lproj</code> directory. For example, specify French messages in `fr.lproj/Localizable.strings`:

   ```
   "NOTIFICATION_TITLE" = "Bonjour le monde";
   "NOTIFICATION_MESSAGE" = "C'est un message";
   ```

   The message payload would look like this:

   ```json
   {
     "data": {
       "title_loc_key": "NOTIFICATION_TITLE",
       "body_loc_key": "NOTIFICATION_MESSAGE"
     },
   }
   ```


## Enable message delivery data export

You can export your message data into BigQuery for further analysis. BigQuery allows you to analyze the data using BigQuery SQL,
export it to another cloud provider, or use the data for your custom ML models. An export to BigQuery
includes all available data for messages, regardless of message type or whether the message is sent via
the API or the Notifications composer.

To enable the export, first follow the steps [described here](https://firebase.google.com/docs/cloud-messaging/understand-delivery?platform=ios#bigquery-data-export),
then follow these instructions:

### Android

You can use the following code:
```dart
await FirebaseMessaging.instance.setDeliveryMetricsExportToBigQuery(true);
```

### iOS

For iOS, you need to change the `AppDelegate.m` with the following content.

```objective-c
#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import <Firebase/Firebase.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userInfo
          fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
  [[FIRMessaging extensionHelper] exportDeliveryMetricsToBigQueryWithMessageInfo:userInfo];
}

@end
```

### Web

For Web, you need to change your service worker in order to use the v9 version of the SDK.
The v9 version needs to be bundled, so you need to use a bundler like `esbuild` for instance
to get the service worker to work.
See [the example app](https://github.com/firebase/flutterfire/blob/master/packages/firebase_messaging/firebase_messaging/example/bundled-service-worker) to see how to achieve this.

Once you've migrated to the v9 SDK, you can use the following code:

``` typescript
import {
  experimentalSetDeliveryMetricsExportedToBigQueryEnabled,
  getMessaging,
} from 'firebase/messaging/sw';

...

const messaging = getMessaging(app);
experimentalSetDeliveryMetricsExportedToBigQueryEnabled(messaging, true);
```

Don't forget to run `yarn build` in order to export the new version of your service worker to the `web` folder.
