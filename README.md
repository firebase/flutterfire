<p align="center">
  <a href="https://firebase.google.com/docs/flutter">
    <img width="250px" src=".github/images/flutterfire_300x.png" alt="Flutter + Firebase logo"><br/>
  </a>
  <h1 align="center">FlutterFire</h1>
</p>

<p align="center">
  <a href="https://twitter.com/flutterfiredev">
    <img src="https://img.shields.io/twitter/follow/flutterfiredev.svg?colorA=1da1f2&colorB=&label=Follow%20on%20Twitter&style=flat-square" alt="Follow on Twitter" />
  </a>
  <a href="https://github.com/invertase/melos">
    <img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square" alt="Maintained with Melos" />
  </a>
</p>

---

[[Changelog]](./CHANGELOG.md) • [[Packages]](https://pub.dev/publishers/firebase.google.com/packages)

---

FlutterFire is a set of [Flutter plugins](https://flutter.io/platform-plugins/)
that enable Flutter apps to use [Firebase](https://firebase.google.com/) services. You can follow an example that shows
how to use these plugins in
the [Firebase for Flutter](https://firebase.google.com/codelabs/firebase-get-to-know-flutter) codelab.

[Flutter](https://flutter.dev) is Google’s UI toolkit for building beautiful, natively compiled applications for mobile,
web, and desktop from a single codebase. Flutter is used by developers and organizations around the world, and is free
and open source.

---

## Documentation

- [Add Firebase to your Flutter app](https://firebase.google.com/docs/flutter/setup)
- [Available plugins](https://firebase.google.com/docs/flutter/setup#available-plugins)
- [FlutterFire UI](./packages/flutterfire_ui/README.md) (beta)
- [Firestore ODM](./packages/cloud_firestore_odm/README.md) (alpha)

---

## Stable Plugins

| Name                   | pub.dev                                                                                                                                             | Firebase Product                                                                                                                                                             | Documentation                                                     | View Source                                                                                                                     | Android | iOS | Web | MacOS |
|------------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------:|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:-------------------------------------------------------------------:|:---------------------------------------------------------------------------------------------------------------------------------:|:---------:|:-----:|:-----:|:-------:|
| Analytics              | [![Analytics pub.dev badge](https://img.shields.io/pub/v/firebase_analytics.svg)](https://pub.dev/packages/firebase_analytics)                      | [🔗](https://firebase.google.com/products/analytics)                 | [📖](https://firebase.flutter.dev/docs/analytics/overview)        | [`firebase_analytics`](https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_analytics)                 | ✔       | ✔   | ✔   | β     |
| Authentication         | [![Authentication pub.dev badge](https://img.shields.io/pub/v/firebase_auth.svg)](https://pub.dev/packages/firebase_auth)                           | [🔗](https://firebase.google.com/products/auth)                      | [📖](https://firebase.flutter.dev/docs/auth/overview)             | [`firebase_auth`](https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_auth)                           | ✔       | ✔   | ✔   | β     |
| Cloud Firestore        | [![Cloud Firestore pub.dev badge](https://img.shields.io/pub/v/cloud_firestore.svg)](https://pub.dev/packages/cloud_firestore)                      | [🔗](https://firebase.google.com/products/firestore)                 | [📖](https://firebase.flutter.dev/docs/firestore/overview)        | [`cloud_firestore`](https://github.com/FirebaseExtended/flutterfire/tree/master/packages/cloud_firestore)                       | ✔       | ✔   | ✔   | β     |
| Cloud Functions        | [![Cloud Functions pub.dev badge](https://img.shields.io/pub/v/cloud_functions.svg)](https://pub.dev/packages/cloud_functions)                      | [🔗](https://firebase.google.com/products/functions)                 | [📖](https://firebase.flutter.dev/docs/functions/overview)        | [`cloud_functions`](https://github.com/FirebaseExtended/flutterfire/tree/master/packages/cloud_functions)                       | ✔       | ✔   | ✔   | β     |
| Cloud Messaging        | [![Cloud Messaging pub.dev badge](https://img.shields.io/pub/v/firebase_messaging.svg)](https://pub.dev/packages/firebase_messaging)                | [🔗](https://firebase.google.com/products/cloud-messaging)           | [📖](https://firebase.flutter.dev/docs/messaging/overview)        | [`firebase_messaging`](https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_messaging)                 | ✔       | ✔   | ✔   | β     |
| Cloud Storage          | [![Cloud Storage pub.dev badge](https://img.shields.io/pub/v/firebase_storage.svg)](https://pub.dev/packages/firebase_storage)                      | [🔗](https://firebase.google.com/products/storage)                   | [📖](https://firebase.flutter.dev/docs/storage/overview)          | [`firebase_storage`](https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_storage)                     | ✔       | ✔   | ✔   | β     |
| Core                   | [![Core pub.dev badge](https://img.shields.io/pub/v/firebase_core.svg)](https://pub.dev/packages/firebase_core)                                     | [🔗](https://firebase.google.com)                                    | [📖](https://firebase.flutter.dev/docs/core/usage)                | [`firebase_core`](https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_core)                           | ✔       | ✔   | ✔   | β     |
| Crashlytics            | [![Crashlytics pub.dev badge](https://img.shields.io/pub/v/firebase_crashlytics.svg)](https://pub.dev/packages/firebase_crashlytics)                | [🔗](https://firebase.google.com/products/crashlytics)               | [📖](https://firebase.flutter.dev/docs/crashlytics/overview)      | [`firebase_crashlytics`](https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_crashlytics)             | ✔       | ✔   | N/A | β     |
| Dynamic Links          | [![Dynamic Links pub.dev badge](https://img.shields.io/pub/v/firebase_dynamic_links.svg)](https://pub.dev/packages/firebase_dynamic_links)          | [🔗](https://firebase.google.com/products/dynamic-links)             | [📖](https://firebase.flutter.dev/docs/dynamic-links/overview)    | [`firebase_dynamic_links`](https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_dynamic_links)         | ✔       | ✔   | N/A | N/A   |
| In-App Messaging       | [![In-App Messaging pub.dev badge](https://img.shields.io/pub/v/firebase_in_app_messaging.svg)](https://pub.dev/packages/firebase_in_app_messaging) | [🔗](https://firebase.google.com/products/in-app-messaging)          | [📖](https://firebase.flutter.dev/docs/in-app-messaging/overview) | [`firebase_in_app_messaging`](https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_in_app_messaging)   | ✔       | ✔   | N/A | N/A   |
| Installations          | [![Installations pub.dev badge](https://img.shields.io/pub/v/firebase_app_installations.svg)](https://pub.dev/packages/firebase_app_installations)  | [🔗](https://firebase.google.com/docs/projects/manage-installations) | [📖](https://firebase.flutter.dev/docs/installations/overview)    | [`firebase_app_installations`](https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_app_installations) | ✔       | ✔   | ✔   | β     |
| Performance Monitoring | [![Performance Monitoring pub.dev badge](https://img.shields.io/pub/v/firebase_performance.svg)](https://pub.dev/packages/firebase_performance)     | [🔗](https://firebase.google.com/products/performance)               | [📖](https://firebase.flutter.dev/docs/performance/overview)      | [`firebase_performance`](https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_performance)             | ✔       | ✔   | ✔   | N/A   |
| Realtime Database      | [![Realtime Database pub.dev badge](https://img.shields.io/pub/v/firebase_database.svg)](https://pub.dev/packages/firebase_database)                | [🔗](https://firebase.google.com/products/database)                  | [📖](https://firebase.flutter.dev/docs/database/overview)         | [`firebase_database`](https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_database)                   | ✔       | ✔   | ✔   | β     |
| Remote Config          | [![Remote Config pub.dev badge](https://img.shields.io/pub/v/firebase_remote_config.svg)](https://pub.dev/packages/firebase_remote_config)          | [🔗](https://firebase.google.com/products/remote-config)             | [📖](https://firebase.flutter.dev/docs/remote-config/overview)    | [`firebase_remote_config`](https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_remote_config)         | ✔       | ✔   | ✔   | β     |

## Beta Plugins

| Name      | pub.dev                                                                                                                        | Firebase Product                                                                                                                                         | Documentation                                              | View Source                                                                                                     | Android | iOS | Web | MacOS |
|-----------|:--------------------------------------------------------------------------------------------------------------------------------:|:----------------------------------------------------------------------------------------------------------------------------------------------------------:|:------------------------------------------------------------:|:-----------------------------------------------------------------------------------------------------------------:|:---------:|:-----:|:-----:|:-------:|
| App Check | [![App Check pub.dev badge](https://img.shields.io/pub/v/firebase_app_check.svg)](https://pub.dev/packages/firebase_app_check) | [🔗](https://firebase.google.com/docs/app-check) | [📖](https://firebase.flutter.dev/docs/app-check/overview) | [`firebase_app_check`](https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_app_check) | ✔       | ✔   | ✔   | β     |


## Preview Plugins

| Name                | pub.dev                                                                                                                                                      | Firebase Product                                                                                                                                      | Documentation                                                        | View Source                                                                                                                         | Android | iOS | Web | MacOS |
|---------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------:|:-------------------------------------------------------------------------------------------------------------------------------------------------------:|:----------------------------------------------------------------------:|:-------------------------------------------------------------------------------------------------------------------------------------:|:---------:|:-----:|:-----:|:-------:|
| ML Model Downloader | [![ML Model Downloader pub.dev badge](https://img.shields.io/pub/v/firebase_ml_model_downloader.svg)](https://pub.dev/packages/firebase_ml_model_downloader) | [🔗](https://firebase.google.com/products/ml) | [📖](https://firebase.flutter.dev/docs/ml-model-downloader/overview) | [`firebase_ml_model_downloader`](https://github.com/FirebaseExtended/flutterfire/tree/master/packages/firebase_ml_model_downloader) | ✔       | ✔   | N/A | β     |

## Alpha Plugins

| Name                | pub.dev                                                                                                                                    | Firebase Product                                                                                                                          | Documentation                                                  | View Source                                                                                                       | Android | iOS | Web | MacOS |
|---------------------|:--------------------------------------------------------------------------------------------------------------------------------------------:|:-------------------------------------------------------------------------------------------------------------------------------------------:|:----------------------------------------------------------------:|:-------------------------------------------------------------------------------------------------------------------:|:---------:|:-----:|:-----:|:-------:|
| Cloud Firestore ODM | [![Cloud Firestore ODM pub.dev badge](https://img.shields.io/pub/v/cloud_firestore_odm.svg)](https://pub.dev/packages/cloud_firestore_odm) | [🔗](https://firebase.google.com) | [📖](https://firebase.flutter.dev/docs/firestore-odm/overview) | [`cloud_firestore_odm`](https://github.com/FirebaseExtended/flutterfire/tree/master/packages/cloud_firestore_odm) | ✔       | ✔   | ✔   | β     |

## Issues

Please file FlutterFire specific issues, bugs, or feature requests in
our [issue tracker](https://github.com/firebase/flutterfire/issues/new/choose).

Plugin issues that are not specific to FlutterFire can be filed in
the [Flutter issue tracker](https://github.com/flutter/flutter/issues/new).

## Contributing

If you wish to contribute a change to any of the existing plugins in this repo, please review
our [contribution guide](https://github.com/firebase/flutterfire/blob/master/CONTRIBUTING.md)
and open a [pull request](https://github.com/firebase/flutterfire/pulls).
