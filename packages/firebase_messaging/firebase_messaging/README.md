[<img src="https://raw.githubusercontent.com/firebase/flutterfire/main/.github/images/flutter_favorite.png" width="200" />](https://flutter.dev/docs/development/packages-and-plugins/favorites)

# Firebase Messaging Plugin for Flutter

A Flutter plugin to use the [Firebase Cloud Messaging API](https://firebase.google.com/docs/cloud-messaging).

To learn more about Firebase Cloud Messaging, please visit the [Firebase website](https://firebase.google.com/products/cloud-messaging)

[![pub package](https://img.shields.io/pub/v/firebase_messaging.svg)](https://pub.dev/packages/firebase_messaging)

## Getting Started

To get started with Firebase Cloud Messaging for Flutter, please [see the documentation](https://firebase.google.com/docs/cloud-messaging).

## Usage

To use this plugin, please visit the [Cloud Messaging Usage documentation](https://firebase.google.com/docs/cloud-messaging)

### iOS apps using UIScene

Apps that adopt the UIScene lifecycle register Flutter plugins after
`application:didFinishLaunchingWithOptions:`. Apple requires
`UNUserNotificationCenter.delegate` to be configured before that method returns, so configure
Firebase Messaging explicitly from your app delegate:

```objectivec
#import <firebase_messaging/FLTFirebaseMessagingPlugin.h>

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [FLTFirebaseMessagingPlugin configureNotificationCenterDelegate];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
```

## Issues and feedback

Please file FlutterFire specific issues, bugs, or feature requests in our [issue tracker](https://github.com/firebase/flutterfire/issues/new).

Plugin issues that are not specific to FlutterFire can be filed in the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).

To contribute a change to this plugin,
please review our [contribution guide](https://github.com/firebase/flutterfire/blob/main/CONTRIBUTING.md)
and open a [pull request](https://github.com/firebase/flutterfire/pulls).
