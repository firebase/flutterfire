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

## Handling interaction

When users tap a notification, the default behavior on both Android & iOS is to open the application. If the application is terminated,
it will be started, and if it is in the background, it will be brought to the foreground.

Depending on the content of a notification, you may want to handle the user's interaction when the application
opens. For example, if a new chat message is sent using a notification and the user selects it, you may want to
 open the specific conversation when the application opens.

The `firebase-messaging` package provides two ways to handle this interaction:

1. `getInitialMessage()`: If the application is opened from a terminated state, this method returns a `Future` containing a `RemoteMessage`. Once consumed, the `RemoteMessage` will be removed.
2. `onMessageOpenedApp`: A `Stream` which posts a `RemoteMessage` when the application is opened from a
    background state.

To ensure a smooth experience for your users, you should handle both scenarios. The code example
below outlines how this can be achieved:

```dart
class Application extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Application();
}

class _Application extends State<Application> {
  // In this example, suppose that all messages contain a data field with the key 'type'.
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

How you handle interaction depends on your application setup. The example above
shows a basic example of using a `StatefulWidget`.

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

