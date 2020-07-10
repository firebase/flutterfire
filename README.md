<p align="center">
  <a href="https://firebase.flutter.dev">
    <img width="250px" src="website/static/img/flutterfire_300x.png"><br/>
  </a>
  <h1 align="center">FlutterFire</h2>
</p>

<p align="center">
  <a href="https://github.com/FirebaseExtended/flutterfire/actions?query=workflow%3Aall_plugins">
    <img src="https://github.com/FirebaseExtended/flutterfire/workflows/all_plugins/badge.svg" alt="all_plugins GitHub Workflow Status"/>
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

 - [Authentication (`firebase_auth`)](#firebase_auth)
 - [Core (`firebase_core`)](#firebase_core)

---

### `firebase_auth`

> ![firebase_auth][auth_badge_ci] ![firebase_auth][auth_badge_pub]

Firebase Authentication provides easy-to-use APIs to authenticate users to your app. It supports authentication using passwords, phone numbers, popular federated identity providers like Google, Facebook and Twitter, and more. [[Learn More][auth_product]]

[[View Documentation][auth_product]] [[View Source][auth_code]]

#### Platform Support

| Android | iOS | MacOS | Web |
|:-------:|:---:|:-----:|:---:|
|    ✔️    |  ✔️  |   ✔️   |  ✔️  |

----

### `firebase_core`

> ![firebase_core][core_badge_ci] ![firebase_core][core_badge_pub]

Firebase Core provides APIs to manage your Firebase application instances and credentials.

[[View Documentation][core_docs]] [[View Source][core_code]]

#### Platform Support

| Android | iOS | MacOS | Web |
|:-------:|:---:|:-----:|:---:|
|    ✔️    |  ✔️  |   ✔️   |  ✔️  |



----

## Issues

Please file FlutterFire specific issues, bugs, or feature requests in our [issue tracker](https://github.com/FirebaseExtended/flutterfire/issues/new).

Plugin issues that are not specific to FlutterFire can be filed in the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).

## Contributing

If you wish to contribute a change to any of the existing plugins in this repo,
please review our [contribution guide](https://github.com/FirebaseExtended/flutterfire/blob/master/CONTRIBUTING.md),
and send a [pull request](https://github.com/FirebaseExtended/flutterfire/pulls).


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

[crash_pub]: https://pub.dartlang.org/packages/firebase_crashlytics
[crash_product]: https://firebase.google.com/products/crashlytics/
[crash_code]: https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_crashlytics
[crash_badge_pub]: https://img.shields.io/pub/v/firebase_crashlytics.svg

[database_pub]: https://pub.dartlang.org/packages/firebase_database
[database_product]: https://firebase.google.com/products/database/
[database_code]: https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_database
[database_badge_pub]: https://img.shields.io/pub/v/firebase_database.svg

[dynamic_links_pub]: https://pub.dartlang.org/packages/firebase_dynamic_links
[dynamic_links_product]: https://firebase.google.com/products/dynamic-links/
[dynamic_links_code]: https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_dynamic_links
[dynamic_links_badge_pub]: https://img.shields.io/pub/v/firebase_dynamic_links.svg

[firestore_pub]: https://pub.dartlang.org/packages/cloud_firestore
[firestore_product]: https://firebase.google.com/products/firestore/
[firestore_code]: https://github.com/FirebaseExtended/flutterfire/tree/master/packages/cloud_firestore
[firestore_badge_pub]: https://img.shields.io/pub/v/cloud_firestore.svg

[functions_pub]: https://pub.dartlang.org/packages/cloud_functions
[functions_product]: https://firebase.google.com/products/functions/
[functions_code]: https://github.com/FirebaseExtended/flutterfire/tree/master/packages/cloud_functions
[functions_badge_pub]: https://img.shields.io/pub/v/cloud_functions.svg

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
