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

| State          | Description                                                      |
| -------------- | ---------------------------------------------------------------- |
| **Foreground** | When the application is open, in view and in use.                |
| **Background** | When the application is open, but in the background (minimized). |
: : This typically occurs when the user has pressed the "home" button
: : on the device, has switched to another app using the app switcher,
: : or has the application open in a different tab (web).
| **Terminated** | When the device is locked or the application is not running.

There are a few preconditions which must be met before the application can
receive message payloads using FCM:

- The application must have opened at least once (to allow for registration with FCM).
- On iOS, if the user swipes away the application from the app switcher, it must be manually reopened for background messages to start working again.
- On Android, if the user force-quits the app from device settings, it must be manually reopened for messages to start working.
- On web, you must have requested a token (using `getToken()`) with your web push certificate.

## Request permission to receive messages {:#permissions}

On iOS, macOS, web and Android 13 (or newer), before FCM payloads can be
received on your device, you must first ask the user's permission.

The `firebase_messaging` package provides an API for requesting permission using the [`requestPermission`](https://pub.dev/documentation/firebase_messaging/latest/firebase_messaging/FirebaseMessaging/requestPermission.html) method.
This API accepts a number of named arguments which define the type of permissions you'd like to request, such as whether
messaging containing notification payloads can trigger a sound or read out messages using Siri. By default,
the method requests sensible default permissions. The reference API provides full documentation on what each permission is for.

To get started, call the method from your application (on iOS a built-in modal will be displayed, on web
the browser's API flow will be triggered):

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

Note: On Android versions prior to 13, `authorizationStatus` returns
`authorized` if the user has not disabled notifications for the app in the
operating system settings. On Android versions 13 and higher, there is no way to determine if the user has chosen whether to grant/deny permission. A `denied` value conveys an undetermined or denied permission state, and it will be up to you to track if a permission request has been made.

The other properties on `NotificationSettings` return whether a specific permission is enabled, disabled or not supported on the current
device.

Once permission has been granted and the different types of device state have been understood, your application can now start to handle the incoming
FCM payloads.

## Message handling {: #message-handling}

Based on your application's current state, incoming payloads of different
[message types](/docs/cloud-messaging/customize-messages/set-message-type)
require different implementations to handle them:

### Foreground messages {: #foreground-messages}

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

#### Foreground and Notification messages {: #foreground-and-notification-messages}

Notification messages which arrive while the application is in the foreground won't display a visible notification by default, on both
Android and iOS. It is, however, possible to override this behavior:

- On Android, you must create a "High Priority" notification channel.
- On iOS, you can update the presentation options for the application.

### Background messages {: #background-messages}

The process of handling background messages is different on Android,
Apple, and web based platforms.

#### Apple platforms and Android {: #apple-android-platforms}

Handle background messages by registering a `onBackgroundMessage` handler. When messages are received, an
isolate is spawned (Android only, iOS/macOS does not require a separate isolate) allowing you to handle messages even when your application is not running.

There are a few things to keep in mind about your background message handler:

1. It must not be an anonymous function.
2. It must be a top-level function (e.g. not a class method which requires initialization).
3. When using Flutter version 3.3.0 or higher, the message handler must be annotated with `@pragma('vm:entry-point')` right above the function declaration (otherwise it may be removed during tree shaking for release mode).

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

#### Web {:#web}
 {:#web}

On the Web, write a JavaScript [Service Worker](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API) which runs in the background.
Use the service worker to handle background messages.

To get started, create a new file in the your `web` directory, and call it `firebase-messaging-sw.js`:

```js title=web/firebase-messaging-sw.js
// See this file for the latest firebase-js-sdk version:
// https://github.com/firebase/flutterfire/blob/main/packages/firebase_core/firebase_core_web/lib/src/firebase_sdk_version.dart
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

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

Next, the worker must be registered. Within the `index.html` file, register the worker by modifying the `<script>` tag which bootstraps Flutter:

```html
<script src="flutter_bootstrap.js" async></script>

<script>
  if ('serviceWorker' in navigator) {
    window.addEventListener('load', function () {
      navigator.serviceWorker.register('firebase-messaging-sw.js', {
        scope: '/firebase-cloud-messaging-push-scope',
      });
    });
  }
</script>
```

If you are still using the old templating system, you can register the worker by modifying the `<script>` tag which bootstraps Flutter as follows:

```html
<html>
<body>
  <script>
      var serviceWorkerVersion = null;
      var scriptLoaded = false;
      function loadMainDartJs() {
        if (scriptLoaded) {
          return;
        }
        scriptLoaded = true;
        var scriptTag = document.createElement('script');
        scriptTag.src = 'main.dart.js';
        scriptTag.type = 'application/javascript';
        document.body.append(scriptTag);
      }

      if ('serviceWorker' in navigator) {
        // Service workers are supported. Use them.
        window.addEventListener('load', function () {
          // Register Firebase Messaging service worker.
          navigator.serviceWorker.register('firebase-messaging-sw.js', {
            scope: '/firebase-cloud-messaging-push-scope',
          });

          // Wait for registration to finish before dropping the <script> tag.
          // Otherwise, the browser will load the script multiple times,
          // potentially different versions.
          var serviceWorkerUrl =
            'flutter_service_worker.js?v=' + serviceWorkerVersion;

          navigator.serviceWorker.register(serviceWorkerUrl).then((reg) => {
            function waitForActivation(serviceWorker) {
              serviceWorker.addEventListener('statechange', () => {
                if (serviceWorker.state == 'activated') {
                  console.log('Installed new service worker.');
                  loadMainDartJs();
                }
              });
            }
            if (!reg.active && (reg.installing || reg.waiting)) {
              // No active web worker and we have installed or are installing
              // one for the first time. Simply wait for it to activate.
              waitForActivation(reg.installing ?? reg.waiting);
            } else if (!reg.active.scriptURL.endsWith(serviceWorkerVersion)) {
              // When the app updates the serviceWorkerVersion changes, so we
              // need to ask the service worker to update.
              console.log('New service worker available.');
              reg.update();
              waitForActivation(reg.installing);
            } else {
              // Existing service worker is still good.
              console.log('Loading app from service worker.');
              loadMainDartJs();
            }
          });

          // If service worker doesn't succeed in a reasonable amount of time,
          // fallback to plaint <script> tag.
          setTimeout(() => {
            if (!scriptLoaded) {
              console.warn(
                'Failed to load app from service worker. Falling back to plain <script> tag.'
              );
              loadMainDartJs();
            }
          }, 4000);
        });
      } else {
        // Service workers not supported. Just drop the <script> tag.
        loadMainDartJs();
      }
  </script>
</body>
```

Next restart your Flutter application. The worker will be registered and any background messages will be handled using this file.

### Handling Interaction {: #handling-interaction}

Since notifications are a visible cue, it is common for users to interact with them (by pressing). The default behavior on both Android and iOS is to open the
application. If the application is terminated it will be started; if it is in the background it will be brought to the foreground.

Depending on the content of a notification, you might want to handle the user's interaction when the application opens. For example, if a new chat message is sent using
a notification and the user presses it, you may want to open the specific conversation when the application opens.

The `firebase-messaging` package provides two ways to handle this interaction:

- `getInitialMessage()`: If the application is opened from a terminated state a `Future` containing a `RemoteMessage` will be returned. Once consumed, the `RemoteMessage` will be removed.
- `onMessageOpenedApp`: A `Stream` which posts a `RemoteMessage` when the application is opened from a background state.

It is recommended that both scenarios are handled to ensure a smooth UX for your users. The following code example outlines how this can be achieved:

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

    // Also handle any interaction when the app is in the background using a
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

How you handle interaction depends on your application setup. The previous example shows a basic illustration using a StatefulWidget.

## Localize Messages {: #localize-messages}

You can send localized strings in two different ways:

- Store the preferred language of each of your users in your server and send customized notifications for each language
- Embed localized strings in your app and make use of the operating system's built-in locale settings

Here's how to use the second method:

### Android {:#android}

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

3. In the server payload, instead of using `title`, `message`, and `body` keys, use `title_loc_key` and `body_loc_key` for your localized message, and set them to the `name` attribute of the message you want to display.

   The message payload would look like this:

   ```json
   {
     "android": {
        "notification": {
          "title_loc_key": "notification_title",
          "body_loc_key": "notification_message"
        }
     }
   }
   ```

### iOS {:#ios}

1. Specify your default-language messages in `Base.lproj/Localizable.strings`:

   ```none
   "NOTIFICATION_TITLE" = "Hello World";
   "NOTIFICATION_MESSAGE" = "This is a message";
   ```

2. Specify the translated messages in the <code><var>language</var>.lproj</code> directory. For example, specify French messages in `fr.lproj/Localizable.strings`:

   ```none
   "NOTIFICATION_TITLE" = "Bonjour le monde";
   "NOTIFICATION_MESSAGE" = "C'est un message";
   ```

   The message payload would look like this:

   ```json
   {
     "apns": {
        "payload": {
          "alert": {
            "title-loc-key": "NOTIFICATION_TITLE",
            "loc-key": "NOTIFICATION_MESSAGE"
          }
        }
     }
   }
   ```

## Enable message delivery data export {: #enable-message-delivery}

You can export your message data into BigQuery for further analysis. BigQuery lets you analyze the data using BigQuery SQL,
export it to another cloud provider, or use the data for your custom ML models. An export to BigQuery
includes all available data for messages, regardless of message type or whether the message is sent using
the API or the Notifications composer.

To enable the export, first follow the steps in the [Understand delivery](https://firebase.google.com/docs/cloud-messaging/understand-delivery?platform=ios#bigquery-data-export) document,
then follow these instructions:

### Android {:#android-2}

You can use the following code:

```dart
await FirebaseMessaging.instance.setDeliveryMetricsExportToBigQuery(true);
```

### iOS {:#ios-2}

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

### Web {:#web-2}

For Web, you need to change your service worker in order to use the v9 version of the SDK.
The v9 version needs to be bundled, so you need to use a bundler like `esbuild`
to get the service worker to work.
See [the example app](https://github.com/firebase/flutterfire/blob/main/packages/firebase_messaging/firebase_messaging/example/bundled-service-worker) to see how to achieve this.

Once you've migrated to the v9 SDK, you can use the following code:

```typescript
import {
  experimentalSetDeliveryMetricsExportedToBigQueryEnabled,
  getMessaging,
} from 'firebase/messaging/sw';
...

const messaging = getMessaging(app);
experimentalSetDeliveryMetricsExportedToBigQueryEnabled(messaging, true);
```

Don't forget to run `yarn build` in order to export the new version of your service worker to the `web` folder.

## Display images in notifications on iOS {: #display-images}

On Apple devices, in order for incoming FCM Notifications to display images from the FCM payload, you must add an additional notification service extension and configure your app to use it.

If you are using Firebase phone authentication, you must add the Firebase Auth pod to your Podfile.

Note: The iOS simulator does not display images in push notifications. You must test on a physical device.

### Step 1 - Add a notification service extension {:#step-1-add-notification-service-extension}

1.  In Xcode, click **File > New > Target...**
1.  A modal will present a list of possible targets; scroll to or use the filter to select **Notification Service Extension**. Click **Next**.
1.  Add a product name (use "ImageNotification" to follow along with this tutorial), select either `Swift` or `Objective-C`, and click **Finish**.
1.  Enable the scheme by clicking **Activate**.

### Step 2 - Add target to the Podfile {:#step-2-add-target-podfile}

* {Swift}

  Ensure that your new extension has access to the `FirebaseMessaging` swift package by adding it to your `Runner` target:

  1.  From the Navigator, [add the Firebase Apple platforms SDK](https://firebase.google.com/docs/ios/setup#add-sdks): **File > Add Package Dependencies...**

  1.  Search or enter package URL:
      ```none
      https://github.com/firebase/firebase-ios-sdk
      ```

  1. Add to Project `Runner`: **Add Package**

  1. Choose FirebaseMessaging and add to target ImageNotification: **Add Package**

* {Objective-C}

  Ensure that your new extension has access to the `Firebase/Messaging` pod by adding it in the Podfile:

  1.  From the Navigator, open the Podfile: **Pods > Podfile**

  1.  Go to the bottom of the file and add:

      ```ruby
      target 'ImageNotification' do
        use_frameworks!
        pod 'Firebase/Auth' # Add this line if you are using FirebaseAuth phone authentication
        pod 'Firebase/Messaging'
      end
      ```

  1.  Install or update your pods using `pod install` from the `ios` or `macos` directory.

### Step 3 - Use the extension helper {:#step-3-ext-helper}

At this point, everything should still be running normally. The final step is invoking the extension helper.

* {Swift}

  1.  From the navigator, select your ImageNotification extension

  1.  Open the `NotificationService.swift` file.

  1.  Replace the content of `NotificationService.swift` with:

      ```swift
      import UserNotifications
      import FirebaseMessaging

      class NotificationService: UNNotificationServiceExtension {

          var contentHandler: ((UNNotificationContent) -> Void)?
          var bestAttemptContent: UNMutableNotificationContent?

          override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
              self.contentHandler = contentHandler
              bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

              Messaging.serviceExtension().populateNotificationContent(bestAttemptContent!, withContentHandler: contentHandler)
          }

          override func serviceExtensionTimeWillExpire() {
              if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
                  contentHandler(bestAttemptContent)
              }
          }
      }
      ```

* {Objective-C}

  1.  From the navigator, select your ImageNotification extension

  1.  Open the `NotificationService.m` file.

  1.  At the top of the file, import `FirebaseMessaging.h` right after the `NotificationService.h`.

      Replace the content of `NotificationService.m` with:

      ```objc
      #import "NotificationService.h"
      #import "FirebaseMessaging.h"
      #import <FirebaseAuth/FirebaseAuth-Swift.h> // Add this line if you are using FirebaseAuth phone authentication
      #import <UIKit/UIKit.h> // Add this line if you are using FirebaseAuth phone authentication

      @interface NotificationService () <NSURLSessionDelegate>

      @property(nonatomic) void (^contentHandler)(UNNotificationContent *contentToDeliver);
      @property(nonatomic) UNMutableNotificationContent *bestAttemptContent;

      @end

      @implementation NotificationService

      /* Uncomment this if you are using Firebase Auth
      - (BOOL)application:(UIApplication *)app
                  openURL:(NSURL *)url
                  options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
        if ([[FIRAuth auth] canHandleURL:url]) {
          return YES;
        }
        return NO;
      }

      - (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
        for (UIOpenURLContext *urlContext in URLContexts) {
          [FIRAuth.auth canHandleURL:urlContext.URL];
        }
      }
      */

      - (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
          self.contentHandler = contentHandler;
          self.bestAttemptContent = [request.content mutableCopy];

          // Modify the notification content here...
          [[FIRMessaging extensionHelper] populateNotificationContent:self.bestAttemptContent withContentHandler:contentHandler];
      }

      - (void)serviceExtensionTimeWillExpire {
          // Called just before the extension will be terminated by the system.
          // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
          self.contentHandler(self.bestAttemptContent);
      }

      @end
      ```

### Step 4 - Add the image to the payload {:#add-image-payload}

In your notification payload, you can now add an image. See the iOS documentation on [how to build a send request](https://firebase.google.com/docs/cloud-messaging/ios/send-image#build_the_send_request). Keep in mind that a 300KB max image size is enforced by the device.
