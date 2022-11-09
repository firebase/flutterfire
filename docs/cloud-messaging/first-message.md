Project: /docs/cloud-messaging/_project.yaml
Book: /docs/_book.yaml
page_type: guide

{% include "_shared/apis/console/_local_variables.html" %}
{% include "_local_variables.html" %}
{% include "docs/cloud-messaging/_local_variables.html" %}
{% include "docs/android/_local_variables.html" %}

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Send a test message to a backgrounded app

To get started with FCM, build out the simplest use case: sending a
test notification message from the
<a href="//console.firebase.google.com/project/_/notification">
Notifications composer</a> to a development device
when the app is in the background on the device.
This page lists all the steps to achieve this, from setup to verification
&mdash; it may cover steps you already completed if you
have [set up a Flutter app](/docs/cloud-messaging/flutter/client)
for FCM.

Important: This guide focuses on the background case. If you want to receive
messages when your app is in the foreground as well, see also
[Receive Messages in a Flutter App](/docs/cloud-messaging/flutter/receive).


## Install the FCM plugin

1.  [Install and initialize the Firebase SDKs for Flutter](/docs/flutter/setup)
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

To send a message to a specific device, you need to know that device's
registration token. Because you'll need to enter the token in a field in the
Notifications console to complete this tutorial, make sure to copy the token
or securely store it after you retrieve it.

To retrieve the current registration token for an app instance, call
`getToken()`. If notification permission has not been granted, this method will
ask the user for notification permissions. Otherwise, it returns a token or
rejects the future due to an error.

```dart
final fcmToken = await FirebaseMessaging.instance.getToken();
```


## Send a test notification message

{# Google-internal include #}
<<../_send-to-device.md>>

For insight into message delivery to your app, see the
<a href="//console.firebase.google.com/project/_/notification/reporting">FCM reporting dashboard</a>,
which records the number of messages sent and opened on Apple and Android
devices, along with data for "impressions" (notifications seen by users) for
Android apps.


## Next steps

### Send messages to foregrounded apps

Once you have successfully sent notification messages while your app is in
the background, see
[Receive Messages in a Flutter App](/docs/cloud-messaging/flutter/receive)
to get started sending to foregrounded apps.

### Go beyond notification messages

To add other, more advanced behavior to your app, you'll need a
[server implementation](/docs/cloud-messaging/server).

Then, in your app client:

- [Receive messages](/docs/cloud-messaging/flutter/receive)
- [Subscribe to message topics](/docs/cloud-messaging/flutter/topic-messaging)

