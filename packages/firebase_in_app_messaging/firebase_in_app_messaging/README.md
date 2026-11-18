# Firebase In-App Messaging Plugin for Flutter

A Flutter plugin to use the [Firebase In-App Messaging API](https://firebase.google.com/docs/in-app-messaging/).

To learn more about Firebase In-App Messaging, please visit the [Firebase website](https://firebase.google.com/products/in-app-messaging)

[![pub package](https://img.shields.io/pub/v/cloud_firestore.svg)](https://pub.dev/packages/firebase_in_app_messaging)

## Getting Started

To get started with Firebase In-App Messaging for Flutter, please [see the documentation](https://firebase.google.com/docs/in-app-messaging/get-started?platform=flutter).

## Usage

To use this plugin, please visit the [Firebase In-App Messaging Usage documentation](https://firebase.google.com/docs/in-app-messaging/get-started?platform=flutter)

### Message lifecycle events

Listen to the streams below to react to what happens to the messages of your
campaigns, for example to handle the URL of the button a user tapped yourself:

```dart
FirebaseInAppMessaging.instance.onMessageClicked.listen((event) {
  print('${event.campaignMetadata.campaignName} -> ${event.action.actionUrl}');
});
```

`onMessageImpression`, `onMessageDismissed` and `onMessageDisplayError` report
the rest of the message lifecycle.

### Custom Flutter display

To render campaigns with your own widgets instead of the native templates:

```dart
FirebaseInAppMessaging.instance.onMessageDisplay.listen((message) async {
  await message.impress();
  // Draw your own UI, then:
  // await message.click(message.action!);
  // await message.dismiss();
});

await FirebaseInAppMessaging.instance.setCustomDisplayEnabled(true);
```

The plugin does not open action URLs. You must report impress / click / dismiss
so campaign analytics keep working.

## Issues and feedback

Please file FlutterFire specific issues, bugs, or feature requests in our [issue tracker](https://github.com/firebase/flutterfire/issues/new).

Plugin issues that are not specific to FlutterFire can be filed in the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).

To contribute a change to this plugin,
please review our [contribution guide](https://github.com/firebase/flutterfire/blob/main/CONTRIBUTING.md)
and open a [pull request](https://github.com/firebase/flutterfire/pulls).
