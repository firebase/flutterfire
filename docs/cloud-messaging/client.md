<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Set up a Firebase Cloud Messaging client app on Flutter

Depending on the platform you're targeting, there are some additional required setup steps that you'll need to take.

## iOS+

### Enable app capabilities in Xcode

Before your application can start to receive messages, you must enable push
notifications and background modes in your Xcode project.

1.  Open your Xcode project workspace (`ios/Runner.xcworkspace`).
1.  [Enable push notifications](https://help.apple.com/xcode/mac/current/#/devdfd3d04a1){:.external}.
1.  Enable the **Background fetch** and the **Remote notifications**
    [background execution modes](https://developer.apple.com/documentation/xcode/configuring-background-execution-modes){:.external}.

#### Upload your APNs authentication key

Before you use FCM, upload your APNs authentication key to Firebase. If you don't
already have an APNs authentication key, create one in the
[Apple Developer Member Center](https://developer.apple.com/membercenter/index.action).

1.  Inside your project in the Firebase console, select the gear icon, select
    **Project Settings**, and then select the **Cloud Messaging** tab.
1.  Select the **Upload** button for your development authentication key,
    your production authentication key, or both. At least one is required.
1.  For each authentication key, select the .p8 file, and provide the key ID and your Apple team ID. Select **Save**.

#### Method swizzling

To use the FCM Flutter plugin on Apple devices, method
swizzling is required. Without it, key Firebase features such as
FCM token handling won't function properly.

## Android

### Google Play services

FCM clients require devices running Android 4.4 or higher that also have Google
Play services installed, or an emulator running Android 4.4 with Google APIs.
Note that you are not limited to deploying your Android apps through Google Play
Store.

Apps that rely on the Play Services SDK should always check the device for a
compatible Google Play services APK before accessing Google Play services
features. It is recommended to do this in two places: in the main activity's
`onCreate()` method, and in its `onResume()` method. The check in `onCreate()`
ensures that the app can't be used without a successful check. The check in
`onResume()` ensures that if the user returns to the running app through some
other means, such as through the back button, the check is still performed.

If the device doesn't have a compatible version of Google Play services, your
app can call [`GoogleApiAvailability.makeGooglePlayServicesAvailable()`](//developers.google.com/android/reference/com/google/android/gms/common/GoogleApiAvailability.html#public-methods) to allow users to download Google Play services from the Play Store.

## Web

### Configure Web Credentials with FCM

The FCM Web interface uses Web credentials called Voluntary Application Server
Identification, or "VAPID" keys, to authorize send requests to supported web
push services. To subscribe your app to push notifications, you need to
associate a pair of keys with your Firebase project. You can either generate a
new key pair or import your existing key pair through the Firebase console.

##### Generate a new key pair

1.  Open the [Cloud Messaging](//console.firebase.google.com/project/_/settings/cloudmessaging/)
    tab of the Firebase console **Settings** pane and scroll to the
    **Web configuration** section.

1.  In the **Web Push certificates** tab, click **Generate Key Pair**. The
    console displays a notice that the key pair was generated, and displays the
    public key string and date added.

##### Import an existing key pair

If you have an existing key pair you are already using with your web app, you
can import it to FCM so that you can reach your existing web app
instances through FCM APIs. To import keys, you must have
owner-level access to the Firebase project. Import your existing public and
private key in base64 URL safe encoded form:

1.  Open the [Cloud Messaging](//console.firebase.google.com/project/_/settings/cloudmessaging/)
    tab of the Firebase console **Settings** pane and scroll to the
    **Web configuration** section.

1.  In the **Web Push certificates** tab, find and select the link text, "import
    an existing key pair."

1.  In the **Import a key pair** dialog, provide your public and private keys in
    the corresponding fields and click **Import**. The console displays the
    public key string and date added.

For more information about the format of the keys and how to generate them,
see [Application server keys](https://developers.google.com/web/fundamentals/push-notifications/web-push-protocol#application_server_keys).


## Install the FCM plugin


1.  [Install and initialize the Firebase plugins for Flutter](/docs/flutter/setup)
    if you haven't already done so.

1.  From the root of your Flutter project, run the following command to install
    the plugin:

    ```bash
    flutter pub add firebase_messaging
    ```

1.  Once complete, rebuild your Flutter application:

    ```bash
    flutter run
    ```

## Access the registration token

To send a message to a specific device, you need to know the device
registration token. To retrieve the current registration token for an app instance, call
`getToken()`.

On Apple and Android platforms, `getToken()` does not request notification
permission. If your app displays notifications, request permission explicitly:

```dart
final notificationSettings =
    await FirebaseMessaging.instance.requestPermission(provisional: true);
```

On web, `getToken()` asks for notification permission if it has not already
been granted. You can call `requestPermission()` first if you want to control
when the browser displays the permission prompt.

Warning: In iOS SDK 10.4.0 and higher, it is required that the APNs token
is available before retrieving the FCM token. The APNs token is not guaranteed
to be available immediately after permission is granted. If `getAPNSToken()`
returns `null`, wait for APNs registration to complete and try again later.

```dart
// On Apple platforms, ensure the APNs token is available before retrieving
// the FCM token.
final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
if (apnsToken != null) {
  final fcmToken = await FirebaseMessaging.instance.getToken();
}
```

On other native platforms, retrieve the token directly:

```dart
final fcmToken = await FirebaseMessaging.instance.getToken();
```

On web platforms, pass your VAPID public key to `getToken()`:

```dart
final fcmToken = await FirebaseMessaging.instance.getToken(vapidKey: "BKagOny0KF_2pCJQ3m....moL0ewzQ8rZu");
```

On Apple and Android platforms, subscribe to the `onTokenRefresh` stream to be
notified whenever a token is generated or refreshed. The stream does not emit
at every app startup. On web, `onTokenRefresh` is a no-op stream.

```dart
FirebaseMessaging.instance.onTokenRefresh
    .listen((fcmToken) {
      // TODO: If necessary send token to application server.

      // This callback is fired whenever a token is generated or refreshed.
    })
    .onError((err) {
      // Error getting token.
    });
```

## Prevent auto initialization {:#prevent-auto-init}

When an FCM registration token is generated, the library uploads
the identifier and configuration data to Firebase. If you prefer to prevent
token autogeneration, disable auto-initialization at build time.

### iOS

On iOS, add a metadata value to your `Info.plist`:

```
FirebaseMessagingAutoInitEnabled = NO
```

### Android

On Android, disable Analytics collection and FCM auto initialization (you must
disable both) by adding these metadata values to your `AndroidManifest.xml`:

```xml
<meta-data
    android:name="firebase_messaging_auto_init_enabled"
    android:value="false" />
<meta-data
    android:name="firebase_analytics_collection_enabled"
    android:value="false" />
```

### Re-enable FCM auto-init at runtime

To enable auto-init for a specific app instance, call `setAutoInitEnabled()`:

```dart
await FirebaseMessaging.instance.setAutoInitEnabled(true);
```

This value persists across app restarts once set.

## Send a test notification message

1. Install and run the app on the target device. On Apple devices, you'll need to accept the request for permission to receive remote notifications.
2. Make sure the app is in the background on the device.
3. In the Firebase console, open the Messaging page.
4. If this is your first message, select **Create your first campaign**. Select **Firebase Notification messages** and select **Create**.
5. Otherwise, on the **Campaign** tab, select **New campaign** and then **Notifications**.
6. Enter the message text.
7. Select **Send test message** from the right pane.
8. In the field labeled **Add an FCM registration token**, enter your registration token.
9. Select **Test**.

After you select **Test**, the targeted client device, with the app in the background, should receive the notification.

For insight into message delivery to your app, see the FCM reporting dashboard, which records the number of messages sent and opened on Apple and Android devices, along with impression data for Android apps.

## Handling interaction

When users tap a notification, the default behavior on both Android and iOS is
to open the application. If the application is terminated, it will be started,
and if it is in the background, it will be brought to the foreground.

Depending on the content of a notification, you may want to handle the user's
interaction when the application opens. For example, if a new chat message is
sent using a notification and the user selects it, you may want to open the
specific conversation when the application opens.

The `firebase-messaging` package provides two ways to handle this interaction:
  1. `getInitialMessage():` If the application is opened from a terminated
     state, this method returns a `Future` containing a `RemoteMessage`. Once
     consumed, the `RemoteMessage` will be removed.
  1. `onMessageOpenedApp`: A`Stream` which posts a `RemoteMessage` when the
     application is opened from a background state.

To make sure your users have a smooth experience, you should handle both
scenarios. The following code example outlines how this can be achieved:

How you handle interactions depends on your application setup. The previously
shown example is a basic example of using a `StatefulWidget`.

## Next steps

After the client app is set up, you can start receiving messages or sending them to your users:
- [Send a test message to a backgrounded app](first-message)
- [Receive messages](/docs/cloud-messaging/flutter/receive)
- [Notification composer](///console.firebase.google.com/project/_/notification)
