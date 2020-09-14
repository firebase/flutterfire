## 2.0.1

 - Fixed 2 race conditions. [(#3251)](https://github.com/FirebaseExtended/flutterfire/pull/3251)
   - When a snapshot stream unsubscribes, the Dart Stream is removed at the same time an async request to remove the native listener is sent. In some cases, an event is sent from native before the native listener has been removed, but after the Dart Stream is removed, causing an assertion error.
   - If a widget updates in a very short period of time, the `onCancel` stream handler is called pretty much straight away. Since setting up the stream handler takes longer than removing, in some edge cases it's trying to remove a listener which hasn't been created.

## 2.0.0

* See `cloud_firestore` plugin changelog.

## 1.1.2

* Update lower bound of dart dependency to 2.0.0.

## 1.1.1

* Fixed formatting in the CHANGELOG.

## 1.1.0

* Updated `FieldValueFactoryPlatform` to use generics.
* `FieldValuePlatform` no longer extends `PlatformInterface`.
* `MethodChannelFieldValue` no longer extends `FieldValuePlatform` and supports equality comparison.
* Fixed the file name of a test.

## 1.0.1

* Make the pedantic dev_dependency explicit.

## 1.0.0

* Created Platform Interface
