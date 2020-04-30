# Google Analytics for Firebase

[![pub package](https://img.shields.io/pub/v/firebase_analytics.svg)](https://pub.dartlang.org/packages/firebase_analytics)

A Flutter plugin to use the [Google Analytics for Firebase API](https://firebase.google.com/docs/analytics/).

For Flutter plugins for other Firebase products, see [README.md](https://github.com/FirebaseExtended/flutterfire/blob/master/README.md).

## Usage
To use this plugin, add `firebase_analytics` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/). You must also configure firebase analytics for each platform project: Android and iOS (see the example folder or https://codelabs.developers.google.com/codelabs/flutter-firebase/#4 for step by step details).

## Track PageRoute Transitions

To track `PageRoute` transitions, add a `FirebaseAnalyticsObserver` to the list of `NavigatorObservers` on your
`Navigator`, e.g. if you're using a `MaterialApp`:

```dart

FirebaseAnalytics analytics = FirebaseAnalytics();

MaterialApp(
  home: MyAppHome(),
  navigatorObservers: [
    FirebaseAnalyticsObserver(analytics: analytics),
  ],
);
```

You can also track transitions within your `PageRoute` (e.g. when the user switches from one tab to another) by
implementing `RouteAware` and subscribing it to `FirebaseAnalyticsObserver`. See [`example/lib/tabs_page.dart`][tabs_page]
for an example of how to wire that up.

## Getting Started

See the [`example`][example] directory for a complete sample app using Google Analytics for Firebase.

[example]: https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_analytics/firebase_analytics/example
[tabs_page]: https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_analytics/firebase_analytics/example/lib/tabs_page.dart

## Issues and feedback

Please file Flutterfire specific issues, bugs, or feature requests in our [issue tracker](https://github.com/FirebaseExtended/flutterfire/issues/new).

Plugin issues that are not specific to Flutterfire can be filed in the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).

To contribute a change to this plugin,
please review our [contribution guide](https://github.com/FirebaseExtended/flutterfire/blob/master/CONTRIBUTING.md),
and send a [pull request](https://github.com/FirebaseExtended/flutterfire/pulls).
