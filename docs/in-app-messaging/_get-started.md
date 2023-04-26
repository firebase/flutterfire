{# This content gets published to the following location:                           #}
{#   https://firebase.google.com/docs/in-app-messaging/get-started?platform=flutter #}

## Before you begin

[Install and initialize the Firebase SDKs for Flutter](/docs/flutter/setup) if you
haven't already done so.

## Add the Firebase In-App Messaging SDK to your project

1.  From the root directory of your Flutter project, run the following
    command to install the Firebase In-App Messaging plugin:

    ```bash
    flutter pub add firebase_in_app_messaging
    ```

1.  Rebuild your project:

    ```bash
    flutter run
    ```

1.  Import the Firebase In-App Messaging plugin:

    ```dart
    import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
    ```

## Send a test message

### Get your app's installation ID

To conserve power, Firebase In-App Messaging only retrieves messages from the
server once per day. That can make testing difficult, so the
Firebase console allows you to specify a test device that displays messages
on demand.

That testing device is determined by a FID.
Find your testing app's FID by checking the console
output when you run your app.

On Android, the message looks like the following:

```
I/FIAM.Headless: Starting InAppMessaging runtime with Installation ID YOUR_INSTALLATION_ID
```

On iOS, run the app with the runtime command argument `-FIRDebugEnabled`:

1.  With your Xcode project open, select **Product > Scheme > Edit scheme...** from
    the top menu bar.
1.  Open the **Arguments** tab of the dialog that pops up.
1.  Click **+ Add items** under **Arguments Passed On Launch**.
1.  Enter "-FIRDebugEnabled" in the newly-created field.
1.  Click **Close**, then run your app.

Once your app starts running, look for the following line in the Xcode console's logs:

```
[Firebase/InAppMessaging][I-IAM180017] Starting InAppMessaging runtime with Firebase Installation ID YOUR_INSTALLATION_ID
```


### Send a message to your testing device

Once you've launched your app on the testing device and you have its
Firebase installation ID (FID), you can try out your Firebase In-App Messaging
setup by sending a test message:

1.  In the {{name_appmanager}}, open [Messaging](https://console.firebase.google.com/project/_/messaging/).
1.  If this is your first campaign, click **Create your first campaign**.
    1. Select **Firebase In-App messages** and click **Create**.
1.  Otherwise, on the **Campaigns** tab, click **New campaign**.
    1. Select **In-App Messaging**.
1.  Enter a **Title** for your first message.
1.  Click **Test on your Device**
1.  Enter your app's Firebase installation ID in the
    **Add an installation ID** field.
1.  Click **Test** to send the message.

Firebase In-App Messaging sends your test message as soon as you click **Test**. To see the
message, you need to close, then reopen the app on your testing device.

To confirm whether your device is a test device, look for one of the following
log messages.

**Android**

```
I/FIAM.Headless: Setting this device as a test device
```

**iOS**

```
[Firebase/InAppMessaging][I-IAM180017] Seeing test message in fetch response. Turn the current instance into a testing instance.
```
