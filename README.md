<p align="center">
  <a href="https://firebase.flutter.dev">
    <img width="250px" src="website/static/img/flutterfire_300x.png"><br/>
  </a>
  <h1 align="center">FlutterFire</h1>
</p>

<p align="center">
  <a href="https://github.com/FirebaseExtended/flutterfire/actions?query=workflow%3Aall_plugins">
    <img src="https://github.com/FirebaseExtended/flutterfire/workflows/all_plugins/badge.svg" alt="all_plugins GitHub Workflow Status"/>
  </a>
  <a href="https://twitter.com/flutterfiredev">
    <img src="https://img.shields.io/twitter/follow/flutterfiredev.svg?colorA=1da1f2&colorB=&label=Follow%20on%20Twitter" alt="Follow on Twitter">
  </a>
</p>

---

FlutterFire is a set of [Flutter plugins](https://flutter.io/platform-plugins/)
that enable Flutter apps to use [Firebase](https://firebase.google.com/) services. You can follow an example that shows how to use these plugins in the [Firebase for Flutter](https://codelabs.developers.google.com/codelabs/flutter-firebase/index.html#0) codelab.

[Flutter](https://flutter.dev) is Google’s UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase. Flutter is used by developers and organizations around the world, and is free and open source.

> *Note*: FlutterFire is still under development (see [roadmap](https://github.com/FirebaseExtended/flutterfire/issues/2582)), and some APIs and platforms might not be available yet.
[Feedback](https://github.com/FirebaseExtended/flutterfire/issues) and [Pull Requests](https://github.com/FirebaseExtended/flutterfire/pulls) are most welcome!

## Plugins

**Table of contents:**

 - [AdMob (`firebase_admob`)](#firebase_admob)
 - [Analytics (`firebase_analytics`)](#firebase_analytics)
 - [Authentication (`firebase_auth`)](#firebase_auth)
 - [Cloud Firestore (`cloud_firestore`)](#cloud_firestore)
 - [Cloud Functions (`cloud_functions`)](#cloud_functions)
 - [Cloud Messaging (`firebase_messaging`)](#firebase_messaging)
 - [Cloud Storage (`firebase_storage`)](#firebase_storage)
 - [Core (`firebase_core`)](#firebase_core)
 - [Crashlytics (`firebase_crashlytics`)](#firebase_crashlytics)
 - [Realtime Database (`firebase_database`)](#firebase_database)

 - [Dynamic Links (`firebase_dynamic_links`)](#firebase_dynamic_links)
 - [In-App Messaging (`firebase_in_app_messaging`)](#firebase_in_app_messaging)
 - [ML Kit Vision (`firebase_ml_vision`)](#firebase_ml_vision)
 - [Performance Monitoring (`firebase_performance`)](#firebase_performance)
 - [Remote Config (`firebase_remote_config`)](#firebase_remote_config)

---

### `firebase_admob`

> [![firebase_admob][admob_badge_pub]][admob_pub]

Google AdMob is a mobile advertising platform that you can use to generate revenue from your app. Using AdMob with Firebase provides you with additional app usage data and analytics capabilities. [[Learn More][admob_product]]

[[View Source][admob_code]]

#### Platform Support

| Android | iOS | MacOS | Web |
|:-------:|:---:|:-----:|:---:|
|    ✔️    |  ✔️  |       |     |

----

### `firebase_analytics`

> [![firebase_analytics][analytics_badge_pub]][analytics_pub]

Google Analytics for Firebase provides automatic captures of certain key application events and user properties, and you can define your own custom events to measure the things that uniquely matter to your application. [[Learn More][analytics_product]]

[[View Source][analytics_code]]

#### Platform Support

| Android | iOS | MacOS | Web |
|:-------:|:---:|:-----:|:---:|
|    ✔️    |  ✔️  |   ✔️   |  ✔️  |

----

### `firebase_auth`

> ![firebase_auth][auth_badge_ci] [![firebase_auth][auth_badge_pub]][auth_pub]

Firebase Authentication provides easy-to-use APIs to authenticate users to your app. It supports authentication using passwords, phone numbers, popular federated identity providers like Google, Facebook and Twitter, and more. [[Learn More][auth_product]]

[[View Source][auth_code]]

#### Platform Support

| Android | iOS | MacOS | Web |
|:-------:|:---:|:-----:|:---:|
|    ✔️    |  ✔️  |   ✔️   |  ✔️  |

----

### `cloud_firestore`

> ![cloud_firestore][firestore_badge_ci] [![cloud_firestore][firestore_badge_pub]][firestore_pub]

Cloud Firestore is a NoSQL document database that lets you easily store, sync, and query data for your mobile and web apps - at global scale. [[Learn More][firestore_product]]

[[View Documentation][firestore_docs]] [[View Source][firestore_code]]

#### Platform Support

| Android | iOS | MacOS | Web |
|:-------:|:---:|:-----:|:---:|
|    ✔️    |  ✔️  |   ✔️   |  ✔️  |

----

### `cloud_functions`

> ![cloud_functions][functions_badge_ci] [![cloud_functions][functions_badge_pub]][functions_pub]

The Cloud Functions for Firebase plugin let you call functions directly from within your app. To call a function from your app in this way, write and deploy an HTTPS Callable function in Cloud Functions, and then add client logic to call the function from your app. [[Learn More][functions_product]]

[[View Source][functions_code]]

#### Platform Support

| Android | iOS | MacOS | Web |
|:-------:|:---:|:-----:|:---:|
|    ✔️    |  ✔️  |   ✔️   |  ✔️  |

----

### `firebase_messaging`

> [![firebase_messaging][messaging_badge_pub]][messaging_pub]

Firebase Cloud Messaging (FCM) provides a reliable and battery-efficient connection between your server and devices that allows you to deliver and receive messages and notifications on iOS & Android, at no cost. [[Learn More][messaging_product]]

[[View Source][messaging_code]]

#### Platform Support

| Android | iOS | MacOS | Web |
|:-------:|:---:|:-----:|:---:|
|    ✔️    |  ✔️  |       |     |

----

### `firebase_storage`

> ![firebase_storage][storage_badge_ci] [![firebase_storage][storage_badge_pub]][storage_pub]

Cloud Storage is designed to help you quickly and easily store and serve user-generated content, such as photos and videos. [[Learn More][storage_product]]

[[View Source][storage_code]]

#### Platform Support

| Android | iOS | MacOS | Web |
|:-------:|:---:|:-----:|:---:|
|    ✔️    |  ✔️  |   ✔️   |     |

----

### `firebase_core`

> ![firebase_core][core_badge_ci] ![firebase_core][core_badge_pub]

Firebase Core provides APIs to manage your Firebase application instances and credentials. This plugin is required by all FlutterFire plugins.

[[View Documentation][core_docs]] [[View Source][core_code]]

#### Platform Support

| Android | iOS | MacOS | Web |
|:-------:|:---:|:-----:|:---:|
|    ✔️    |  ✔️  |   ✔️   |  ✔️  |

----

### `firebase_crashlytics`

> [![firebase_crashlytics][crashlytics_badge_pub]][crashlytics_pub]

Firebase Crashlytics helps you track, prioritize, and fix stability issues that erode app quality, in realtime. Spend less time triaging and troubleshooting crashes and more time building app features that delight users. [[Learn More][crashlytics_product]]

[[View Source][crashlytics_code]]

#### Platform Support

| Android | iOS | MacOS | Web |
|:-------:|:---:|:-----:|:---:|
|    ✔️    |  ✔️  |       |     |

----

### `firebase_database`

> [![firebase_database][database_badge_pub]][database_pub]

The Firebase Realtime Database is a cloud-hosted NoSQL database that lets you store and sync data between your users in realtime. [[Learn More][database_product]]

[[View Source][database_code]]

#### Platform Support

| Android | iOS | MacOS | Web |
|:-------:|:---:|:-----:|:---:|
|    ✔️    |  ✔️  |   ✔️   |     |

----

### `firebase_dynamic_links`

> [![firebase_dynamic_links][dynamic_links_badge_pub]][dynamic_links_pub]

Dynamic Links are smart URLs that allow you to send existing and potential users to any location within your iOS or Android app. [[Learn More][dynamic_links_product]]

[[View Source][dynamic_links_code]]

#### Platform Support

| Android | iOS | MacOS | Web |
|:-------:|:---:|:-----:|:---:|
|    ✔️    |  ✔️  |       |     |

----

### `firebase_in_app_messaging`

> [![firebase_in_app_messaging][in_app_messaging_badge_pub]][in_app_messaging_pub]

Firebase In-App Messaging helps you engage users who are actively using your app by sending them targeted and contextual messages that nudge them to complete key in-app actions - like beating a game level, buying an item, or subscribing to content. [[Learn More][in_app_messaging_product]]

[[View Source][in_app_messaging_code]]

#### Platform Support

| Android | iOS | MacOS | Web |
|:-------:|:---:|:-----:|:---:|
|    ✔️    |  ✔️  |       |     |

----

### `firebase_ml_vision`

> [![firebase_ml_vision][ml_vision_badge_pub]][ml_vision_pub]

Use Firebase ML to train and deploy custom models, or use a more turn-key solution with the Cloud Vision APIs. [[Learn More][ml_vision_product]]

[[View Source][ml_vision_code]]

#### Platform Support

| Android | iOS | MacOS | Web |
|:-------:|:---:|:-----:|:---:|
|    ✔️    |  ✔️  |       |     |

----

### `firebase_performance`

> [![firebase_performance][performance_badge_pub]][performance_pub]

Get insights into how your app performs from your users’ point of view, with automatic and customized performance tracing. [[Learn More][performance_product]]

[[View Source][performance_code]]

#### Platform Support

| Android | iOS | MacOS | Web |
|:-------:|:---:|:-----:|:---:|
|    ✔️    |  ✔️  |       |     |

----

### `firebase_remote_config`

> [![firebase_remote_config][remote_config_badge_pub]][remote_config_pub]

With Firebase Remote Config, you can change the behavior and appearance of your app on the fly from the Firebase console, and then track performance in Google Analytics for Firebase. [[Learn More][remote_config_product]]

[[View Source][remote_config_code]]

#### Platform Support

| Android | iOS | MacOS | Web |
|:-------:|:---:|:-----:|:---:|
|    ✔️    |  ✔️  |       |     |

----

## Issues

Please file FlutterFire specific issues, bugs, or feature requests in our [issue tracker](https://github.com/FirebaseExtended/flutterfire/issues/new).

Plugin issues that are not specific to FlutterFire can be filed in the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).

## Contributing

If you wish to contribute a change to any of the existing plugins in this repo,
please review our [contribution guide](https://github.com/FirebaseExtended/flutterfire/blob/master/CONTRIBUTING.md)
and open a [pull request](https://github.com/FirebaseExtended/flutterfire/pulls).


[admob_pub]: https://pub.dartlang.org/packages/firebase_admob
[admob_product]: https://firebase.google.com/docs/admob/
[admob_code]: https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_admob
[admob_badge_pub]: https://img.shields.io/pub/v/firebase_admob.svg

[analytics_pub]: https://pub.dartlang.org/packages/firebase_analytics
[analytics_product]: https://firebase.google.com/products/analytics/
[analytics_code]: https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_analytics
[analytics_badge_pub]: https://img.shields.io/pub/v/firebase_analytics.svg

[auth_pub]: https://pub.dartlang.org/packages/firebase_auth
[auth_product]: https://firebase.google.com/products/auth/
[auth_code]: https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_auth
[auth_badge_pub]: https://img.shields.io/pub/v/firebase_auth.svg
[auth_badge_ci]: https://github.com/FirebaseExtended/flutterfire/workflows/firebase_auth/badge.svg

[core_pub]: https://pub.dartlang.org/packages/firebase_core
[core_code]: https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_core
[core_docs]: https://firebase.flutter.dev/docs/core/usage
[core_badge_pub]: https://img.shields.io/pub/v/firebase_core.svg
[core_badge_ci]: https://github.com/FirebaseExtended/flutterfire/workflows/firebase_core/badge.svg

[crashlytics_pub]: https://pub.dartlang.org/packages/firebase_crashlytics
[crashlytics_product]: https://firebase.google.com/products/crashlytics/
[crashlytics_code]: https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_crashlytics
[crashlytics_badge_pub]: https://img.shields.io/pub/v/firebase_crashlytics.svg

[database_pub]: https://pub.dartlang.org/packages/firebase_database
[database_product]: https://firebase.google.com/products/database/
[database_code]: https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_database
[database_badge_pub]: https://img.shields.io/pub/v/firebase_database.svg

[dynamic_links_pub]: https://pub.dartlang.org/packages/firebase_dynamic_links
[dynamic_links_product]: https://firebase.google.com/products/dynamic-links/
[dynamic_links_code]: https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_dynamic_links
[dynamic_links_badge_pub]: https://img.shields.io/pub/v/firebase_dynamic_links.svg

[firestore_pub]: https://pub.dartlang.org/packages/cloud_firestore
[firestore_docs]: https://firebase.flutter.dev/docs/firestore/usage
[firestore_product]: https://firebase.google.com/products/firestore/
[firestore_code]: https://github.com/FirebaseExtended/flutterfire/tree/master/packages/cloud_firestore
[firestore_badge_pub]: https://img.shields.io/pub/v/cloud_firestore.svg
[firestore_badge_ci]: https://github.com/FirebaseExtended/flutterfire/workflows/firebase_firestore/badge.svg

[functions_pub]: https://pub.dartlang.org/packages/cloud_functions
[functions_product]: https://firebase.google.com/products/functions/
[functions_code]: https://github.com/FirebaseExtended/flutterfire/tree/master/packages/cloud_functions
[functions_badge_pub]: https://img.shields.io/pub/v/cloud_functions.svg
[functions_badge_ci]: https://github.com/FirebaseExtended/flutterfire/workflows/firebase_functions/badge.svg

[in_app_messaging_pub]: https://pub.dartlang.org/packages/firebase_in_app_messaging
[in_app_messaging_product]: https://firebase.google.com/products/in-app-messaging/
[in_app_messaging_code]: https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_in_app_messaging
[in_app_messaging_badge_pub]: https://img.shields.io/pub/v/firebase_in_app_messaging.svg

[messaging_pub]: https://pub.dartlang.org/packages/firebase_messaging
[messaging_product]: https://firebase.google.com/products/cloud-messaging/
[messaging_code]: https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_messaging
[messaging_badge_pub]: https://img.shields.io/pub/v/firebase_messaging.svg

[ml_vision_pub]: https://pub.dartlang.org/packages/firebase_ml_vision
[ml_vision_product]: https://firebase.google.com/products/ml-kit/
[ml_vision_code]: https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_ml_vision
[ml_vision_badge_pub]: https://img.shields.io/pub/v/firebase_ml_vision.svg

[performance_pub]: https://pub.dartlang.org/packages/firebase_performance
[performance_product]: https://firebase.google.com/products/performance/
[performance_code]: https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_performance
[performance_badge_pub]: https://img.shields.io/pub/v/firebase_performance.svg

[remote_config_pub]: https://pub.dartlang.org/packages/firebase_remote_config
[remote_config_product]: https://firebase.google.com/products/remote-config/
[remote_config_code]: https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_remote_config
[remote_config_badge_pub]: https://img.shields.io/pub/v/firebase_remote_config.svg

[storage_pub]: https://pub.dartlang.org/packages/firebase_storage
[storage_product]: https://firebase.google.com/products/storage/
[storage_code]: https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_storage
[storage_badge_pub]: https://img.shields.io/pub/v/firebase_storage.svg
[storage_badge_ci]: https://github.com/FirebaseExtended/flutterfire/workflows/firebase_storage/badge.svg
