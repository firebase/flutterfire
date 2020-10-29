## 2.1.3

 - Update a dependency to the latest release.

## 2.1.2

 - **FIX**: bubble exceptions (#3701).
 - **FIX**: fix returning of transaction result (#3747).

## 2.1.1

 - **FIX**: typo in code comments (#3655).
 - **DOCS**: remove `updateBlock` reference in Firestore docs (#3728).

## 2.1.0

 - **FIX**: check for Stream existence before sending event (#3435).
 - **FEAT**: add a [] operator to DocumentSnapshot, acting as get() (#3387).
 - **DOCS**: Fixed docs typo (#3471).

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
