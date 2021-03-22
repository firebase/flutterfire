## 1.0.0

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 1.0.0-1.0.nullsafety.0

 - Bump "cloud_firestore" to `1.0.0-1.0.nullsafety.0`.

## 0.17.0-1.0.nullsafety.2

 - **FIX**: Fix type issue. (#5081).
 - **FIX**: Fixed crashes due to null `Settings` (#5031).

## 0.17.0-1.0.nullsafety.1

 - Update a dependency to the latest release.

## 0.17.0-1.0.nullsafety.0

> Note: This release has breaking changes.

 - **BREAKING** **REFACTOR**: migrate to NNBD (#4780).

## 0.16.0

> Note: This release has breaking changes.

 - **FIX**: add missing symlinks (fixes #4628).
 - **FEAT**: add check on podspec to assist upgrading users deployment target.
 - **CHORE**: add missing file license headers.
 - **BUILD**: commit Podfiles with 10.12 deployment target.
 - **BUILD**: remove default sdk version, version should always come from firebase_core, or be user defined.
 - **BUILD**: set macOS deployment target to 10.12 (from 10.11).
 - **BREAKING** **BUILD**: set osx min supported platform version to 10.12.

## 0.15.0

> Note: This release has breaking changes.

 - **FIX**: Add missing sdk version constraints inside example pubspec.yaml (#4604).
 - **FIX**: ensure web FieldValue types are converted (#4247).
 - **FEAT**: Move Snapshot handling into a EventChannel (#4209).
 - **BREAKING** **REFACTOR**: remove all currently deprecated APIs.
 - **BREAKING** **FEAT**: forward port to firebase-ios-sdk v7.3.0.
   - Due to this SDK upgrade, iOS 10 is now the minimum supported version by FlutterFire. Please update your build target version.
 - **CHORE**: harmonize dependencies and version handling.

## 0.14.4

 - **FEAT**: bump android `com.android.tools.build` & `'com.google.gms:google-services` versions (#4269).
 - **CHORE**: Migrate iOS example projects (#4222).

## 0.14.3+1

 - Update a dependency to the latest release.

## 0.14.3

 - **FEAT**: migrate firebase interop files to local repository (#3973).
 - **FEAT**: add not-in & != query support (#3748).
 - **FEAT**: bump `compileSdkVersion` to 29 in preparation for upcoming Play Store requirement.
 - **FEAT** [WEB] `FirebaseFirestore.enablePersistence` now accepts `PersistenceSettings`
 - **FEAT** [WEB] adds `PersistenceSettings` class
 - **FEAT** [WEB] adds support for `FirebaseFirestore.clearPersistence`
 - **FEAT** [WEB] adds support for `FirebaseFirestore.terminate`
 - **FEAT** [WEB] adds support for `FirebaseFirestore.waitForPendingWrites`
 - **FEAT** [WEB] adds support for `SetOptions.mergeFields`
 - **FEAT** [WEB] adds `GetOptions` support for querying against server/cache
 - **FEAT** [WEB] adds support for `Query.limitToLast`
 - **FEAT** [WEB] adds support for `FirebaseFirestore.snapshotsInSync`

## 0.14.2

 - **FEAT**: bump compileSdkVersion to 29 (#3975).
 - **FEAT**: update Firebase iOS SDK version to 6.33.0 (from 6.26.0).
 - **CHORE**: update Firestore example app podfile.

## 0.14.1+3

 - **FIX**: remove unused dart:async import (#3611).
 - **FIX**: fix returning of transaction result (#3747).

## 0.14.1+2

 - Update a dependency to the latest release.

## 0.14.1+1

 - **FIX**: remove listener if available (#3452).
 - **DOCS**: remove `updateBlock` reference in Firestore docs (#3728).

## 0.14.1

 - **FIX**: local dependencies in example apps (#3319).
 - **FIX**: pub.dev score fixes (#3318).
 - **FIX**: add missing deprecated static methods (#3278).
 - **FEAT**: add a [] operator to DocumentSnapshot, acting as get() (#3387).
 - **DOCS**: Fixed docs typo (#3471).

## 0.14.0+2

* Added missing deprecated `Firestore` static methods.

## 0.14.0+1

* Fixed issue #3210 (`Query.orderBy(FieldPath.documentId)` throws exception).
* Fixed issue #3237 (`DocumentReference` not being parsed correctly).
* Bump `cloud_firestore_web` dependency.
* Bump `cloud_firestore_platform_interface` dependency to fix 2 race conditions. [(#3251)](https://github.com/FirebaseExtended/flutterfire/pull/3251)

## 0.14.0

Along with the below changes, the plugin has undergone a quality of life update to better support exceptions thrown. Any Firestore specific errors now return a `FirebaseException`, allowing you to directly access the code (e.g. `permission-denied`) and message.

**`Firestore`**:
- **BREAKING**: `settings()` is now a synchronous setter that accepts a `Settings` instance.
  - **NEW**: This change allows us to support changing Firestore settings (such as using the Firestore emulator) without having to quit the application, e.g. Hot Restarts.
- **BREAKING**: `enablePersistence()` is now a Web only method, use `[Settings.persistenceEnabled]` instead for other platforms.
- **DEPRECATED**: Calling `document()` is deprecated in favor of `doc()`.
- **DEPRECATED**: Class `Firestore` is now deprecated. Use `FirebaseFirestore` instead.
- **DEPRECATED**: Calling `Firestore(app: app)` is now deprecated. Use `FirebaseFirestore.instance` or `FirebaseFirestore.instanceFor(app: app)` instead.
- **NEW**: Added `clearPersistence()` support.
- **NEW**: Added `disableNetwork()` support.
- **NEW**: Added `enableNetwork()` support.
- **NEW**: Added `snapshotInSync()` listener support.
- **NEW**: Added `terminate()` support.
- **NEW**: Added `waitForPendingWrites()` support.
- **FIX**: All document/query listeners & currently in progress transactions are now correctly torn down between Hot Restarts.

**`CollectionReference`**:
- **BREAKING**: Getting a collection parent document via `parent()` has been changed to a getter `parent`.
- **BREAKING**: Getting the collection `path` now always returns the `path` without leading and trailing slashes.
- **DEPRECATED**: Calling `document()` is deprecated in favor of `doc()`.
- **FIX**: Equality checking of `CollectionReference` now does not depend on the original path used to create the `CollectionReference`.

**`Query`**:
- **BREAKING**: The internal query logic has been overhauled to better assert invalid queries locally.
- **DEPRECATED**: Calling `getDocuments()` is deprecated in favor of `get()`.
- **BREAKING**: `getDocuments`/`get` has been updated to accept an instance of `GetOptions` (see below).
- **NEW**: Query methods can now be chained.
- **NEW**: It is now possible to call same-point cursor based queries without throwing (e.g. calling `endAt()` and then `endBefore()` will replace the "end" cursor query with the `endBefore`).
- **NEW**: Added support for the `limitToLast` query modifier.

**`QuerySnapshot`**:
- **DEPRECATED**: `documents` has been deprecated in favor of `docs`.
- **DEPRECATED**: `documentChanges` has been deprecated in favor of `docChanges`.
- **NEW**: `docs` now returns a `List<QueryDocumentSnapshot>` vs `List<DocumentSnapshot>`. This doesn't break existing functionality.

**`DocumentReference`**:
- **BREAKING**: `setData`/`set` has been updated to accept an instance of `SetOptions` (see below, supports `mergeFields`).
- **BREAKING**: `get()` has been updated to accept an instance of `GetOptions` (see below).
- **BREAKING**: Getting a document parent collection via `parent()` has been changed to a getter `parent`.
- **BREAKING**: Getting the document `path` now always returns the `path` without leading and trailing slashes.
- **DEPRECATED**: `documentID` has been deprecated in favor of `id`.
- **DEPRECATED**: `setData()` has been deprecated in favor of `set()`.
- **DEPRECATED**: `updateData()` has been deprecated in favor of `update()`.
- **FIX**: Equality checking of `DocumentReference` now does not depend on the original path used to create the `DocumentReference`.

**`DocumentChange`**:
- **DEPRECATED**: Calling `document()` is deprecated in favor of `doc()`.

**`DocumentSnapshot`**:
- **BREAKING**: The `get data` getter is now a `data()` method instead.
- **DEPRECATED**: `documentID` has been deprecated in favor of `id`.
- **NEW**: Added support for fetching nested snapshot data via the `get()` method. If no data exists at the given path, a `StateError` will be thrown.
- **FIX**: `NaN` values stored in your Firestore instance are now correctly parsed when reading & writing data.
- **FIX**: `INFINITY` values stored in your Firestore instance are now correctly parsed when reading & writing data.
- **FIX**: `-INFINITY` values stored in your Firestore instance are now correctly parsed when reading & writing data.

**`WriteBatch`**:
- **DEPRECATED**: `setData()` has been deprecated in favor of `set()`.
- **DEPRECATED**: `updateData()` has been deprecated in favor of `update()`.
- **BREAKING**: `setData`/`set` now supports `SetOptions` to merge data/fields (previously this accepted a `Map`).

**`Transaction`**:
- **BREAKING**: Transactions have been overhauled to address a number of critical issues:
  - Values returned from the transaction will now be returned from the Future. Previously, only JSON serializable values were supported. It is now possible to return any value from your transaction handler, e.g. a `DocumentSnapshot`.
  - When manually throwing an exception, the context was lost and a generic `PlatformException` was thrown. You can now throw & catch on any exceptions.
  - The modify methods on a transaction (`set`, `delete`, `update`) were previously Futures. These have been updated to better reflect how transactions should behave - they are now synchronous and are executed atomically once the transaction handler block has finished executing.
- **FIX**: Timeouts will now function correctly.
- **FIX**: iOS: transaction completion block incorrectly resolving a `FlutterResult` multiple times.

See the new [transactions documentation](https://firebase.flutter.dev/docs/firestore/usage#transactions) to learn more.

**`FieldPath`**:
- **NEW**: The constructor has now been made public to accept a `List` of `String` values. Previously field paths were accessible only via a dot-notated string path. This meant attempting to access a field in a document with a `.` in the name (e.g. `foo.bar@gmail.com`) was impossible.

**`GetOptions`**: New class created to support how data is fetched from Firestore (`server`, `cache`, `serverAndCache`).

**`SetOptions`**: New class created to both `merge` and `mergeFields` when setting data on documents.

**`GeoPoint`**:
- **BREAKING**: Add latitude and longitude validation when constructing a new `GeoPoint` instance.

## 0.13.7+1

* Fix crash where listeners are not removed when app quits.

## 0.13.7

* Clean up snapshot listeners when Android Activity is destroyed.

## 0.13.6

* Update lower bound of dart dependency to 2.0.0.

## 0.13.5

* Migrate cloud_firestore to android v2 embedding.

## 0.13.4+2

* Fix for missing UserAgent.h compilation failures.

## 0.13.4+1

* Fix crash with pagination with `DocumentReference` (#2044)
* Minor tweaks to integ tests.

## 0.13.4

* Support equality comparison on `FieldValue` instances.
* Updated version of endorsed web implementation.

## 0.13.3+1

* Make the pedantic dev_dependency explicit.

## 0.13.3

* Add macOS support

## 0.13.2+3

* Fixed decoding & encoding platform interface instances in nested maps

## 0.13.2+2

* Fixed crashes when using `FieldValue.arrayUnion` & `FieldValue.arrayRemove` with `DocumentReference` objects

## 0.13.2+1

* Add Web integration documentation to README.

## 0.13.2

* Add web support by default.
* Require Flutter SDK 1.12.13+hotfix.4 or later
* Add web support to the example app.

## 0.13.1+1

* Fixed crashes when using `Query#where` with `DocumentReference` objects

## 0.13.1

* Migrate to `cloud_firestore_platform_interface`.

## 0.13.0+2

* Fixed `persistenceEnabled`, `sslEnabled`, and `timestampsInSnapshotsEnabled` on iOS.

## 0.13.0+1

* Remove the deprecated `author:` field from pubspec.yaml
* Migrate the plugin to the pubspec platforms manifest.
* Bump the minimum Flutter version to 1.10.0.

## 0.13.0

* **Breaking change** Remove use of [deprecated](https://firebase.google.com/docs/reference/android/com/google/firebase/firestore/FirebaseFirestoreSettings.Builder.html#setTimestampsInSnapshotsEnabled(boolean))
  setting `setTimestampsInSnapshotsEnabled`. If you are already setting it to true, just remove the setting. If you are
  setting it to false, you should update your code to expect Timestamps.

## 0.12.11

* Added support for `in` and `array-contains-any` query operators.

## 0.12.10+5

* Moved `.gitignore` which was left behind in previous change.

## 0.12.10+4

* Moved package to `cloud_firestore/cloud_firestore` subdir, to allow for federated implementations.

## 0.12.10+3

* Fixed test that used `FirebaseApp.channel`.

## 0.12.10+2

* Fixed analyzer warnings about unused fields.

## 0.12.10+1

* Formatted method documentations.

## 0.12.10

* Added `FieldPath` class and `FieldPath.documentId` to refer to the document id in queries.
* Added assertions and exceptions that help you building correct queries.

## 0.12.9+8

* Updated README instructions for contributing for consistency with other Flutterfire plugins.

## 0.12.9+7

* Remove AndroidX warning.

## 0.12.9+6

* Cast error.code to long to avoid using NSInteger as %ld format warnings.

## 0.12.9+5

* Fixes a crash on Android when running a transaction without an internet connection.

## 0.12.9+4

* Fix integer conversion warnings on iOS.

## 0.12.9+3

* Updated error handling on Android for transactions to prevent crashes.

## 0.12.9+2

* Fix flaky integration test for `includeMetadataChanges`.

## 0.12.9+1

* Update documentation to reflect new repository location.
* Update unit tests to call `TestWidgetsFlutterBinding.ensureInitialized`.
* Remove executable bit on LICENSE file.

## 0.12.9

* New optional `includeMetadataChanges` parameter added to `DocumentReference.snapshots()`
 and `Query.snapshots()`
* Fix example app crash when the `message` field was not a string
* Internal renaming of method names.

## 0.12.8+1

* Add `metadata` to `QuerySnapshot`.

## 0.12.8

* Updated how document ids are generated to more closely match native implementations.

## 0.12.7+1

* Update google-services Android gradle plugin to 4.3.0 in documentation and examples.

## 0.12.7

* Methods of `Transaction` no longer require `await`.
* Added documentation to methods of `Transaction`.
* Removed an unnecessary log on Android.
* Added an integration test for rapidly incrementing field value.

## 0.12.6

* Support for `orderBy` on map fields (e.g. `orderBy('cake.flavor')`) for
  `startAtDocument`, `startAfterDocument`, `endAtDocument`, and `endBeforeDocument` added.

## 0.12.5+2

* Automatically use version from pubspec.yaml when reporting usage to Firebase.

## 0.12.5+1
* Added support for combining any of `Query.startAtDocument` and `Query.startAfterDocument`
  with any of `Query.endAtDocument` and `Query.endBeforeDocument`.

## 0.12.5

* Makes `startAtDocument`, `startAfterDocument`, `endAtDocument` and `endBeforeDocument` work
  with `Query.collectionGroup` queries.
* Fixes `startAtDocument`, `startAfterDocument`, `endAtDocument` and `endBeforeDocument` to
  also work with a descending order as the last explicit sort order.
* Fixed an integration test by increasing the value of `cacheSizeBytes` to a valid value.

## 0.12.4

* Added support for `Query.collectionGroup`.

## 0.12.3

* Added support for `cacheSizeBytes` to `Firestore.settings`.

## 0.12.2

* Ensure that all channel calls to the Dart side from the Java side are done
  on the UI thread. This change allows Transactions to work with upcoming
  Engine restrictions, which require channel calls be made on the UI thread.
  **Note** this is an Android only change, the iOS implementation was not impacted.
* Updated the Firebase reporting string to `flutter-fire-fst` to be consistent
  with other reporting libraries.

## 0.12.1

* Added support for `Source` to `Query.getDocuments()` and `DocumentReference.get()`.

## 0.12.0+2

* Bump the minimum Flutter version to 1.5.
* Replace invokeMethod with invokeMapMethod wherever necessary.

## 0.12.0+1

* Send user agent to Firebase.

## 0.12.0

* **Breaking change**. Fixed `CollectionReference.parent` to correctly return a `DocumentReference`.
  If you were using the method previously to obtain the parent
  document's id via `collectionReference.parent().id`,
  you will have to use `collectionReference.parent().documentID` now.
* Added `DocumentReference.parent`.

## 0.11.0+2

* Remove iOS dependency on Firebase/Database and Firebase/Auth CocoaPods.

## 0.11.0+1

* Update iOS CocoaPod dependencies to '~> 6.0' to ensure support for `FieldValue.increment`.

## 0.11.0

* Update Android dependencies to latest.

## 0.10.1

* Support for `startAtDocument`, `startAfterDocument`, `endAtDocument`, `endBeforeDocument`.
* Added additional unit and integration tests.

## 0.10.0

* Support for `FieldValue.increment`.
* Remove `FieldValue.type` and `FieldValue.value` from public API.
* Additional integration testing.

## 0.9.13+1

* Added an integration test for transactions.

## 0.9.13

* Remove Gradle BoM to avoid Gradle version issues.

## 0.9.12

* Move Android dependency to Gradle BoM to help maintain compatibility
  with other FlutterFire plugins.

## 0.9.11

* Bump Android dependencies to latest.

# 0.9.10

* Support for cloud_firestore running in the background on Android.
* Fixed a bug in cleanup for DocumentReference.snapshots().
* Additional integration testing.

## 0.9.9

* Remove `invokeMapMethod` calls to prevent crash.

## 0.9.8

* Add metadata field to DocumentSnapshot.

## 0.9.7+2

* Bump the minimum Flutter version to 1.2.0.
* Add template type parameter to `invokeMethod` calls.

## 0.9.7+1

* Update README with example of getting a document.

## 0.9.7

* Fixes a NoSuchMethodError when using getDocuments on iOS (introduced in 0.9.6).
* Adds a driver test for getDocuments.

## 0.9.6

* On iOS, update null checking to match the recommended pattern usage in the Firebase documentation.
* Fixes a case where snapshot errors might result in plugin crash.

## 0.9.5+2

* Fixing PlatformException(Error 0, null, null) which happened when a successful operation was performed.

## 0.9.5+1

* Log messages about automatic configuration of the default app are now less confusing.

## 0.9.5

* Fix an issue on some iOS devices that results in reading incorrect dates.

## 0.9.4

* No longer sends empty snapshot events on iOS when encountering errors.

## 0.9.3

* Fix transactions on iOS when getting snapshot that doesn't exist.

## 0.9.2

* Fix IllegalStateException errors when using transactions on Android.

## 0.9.1

* Fixed Firebase multiple app support in transactions and document snapshots.

## 0.9.0+2

* Remove categories.

## 0.9.0+1

* Log a more detailed warning at build time about the previous AndroidX
  migration.

## 0.9.0

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

## 0.8.2+3

* Resolved "explicit self reference" and "loses accuracy" compiler warnings.

## 0.8.2+2

* Clean up Android build logs. @SuppressWarnings("unchecked")

## 0.8.2+1

* Avoid crash in document snapshot callback.

## 0.8.2

* Added `Firestore.settings`
* Added `Timestamp` class

## 0.8.1+1

* Bump Android dependencies to latest.

## 0.8.1

* Fixed bug where updating arrays in with `FieldValue` always throws an Exception on Android.

## 0.8.0

Note: this version depends on features available in iOS SDK versions 5.5.0 or later.
To update iOS SDK in existing projects run `pod update Firebase/Firestore`.

* Added `Firestore.enablePersistence`
* Added `FieldValue` with all currently supported values: `arrayUnion`, `arrayRemove`, `delete` and
  `serverTimestamp`.
* Added `arrayContains` argument in `Query.where` method.

## 0.7.4

* Bump Android and Firebase dependency versions.

## 0.7.3

* Updated Gradle tooling to match Android Studio 3.1.2.

## 0.7.2

* Fixes crash on Android if a FirebaseFirestoreException happened.

## 0.7.1

* Updated iOS implementation to reflect Firebase API changes.
* Fixed bug in Transaction.get that would fail on no data.
* Fixed error in README.md code sample.

## 0.7.0+2

* Update transactions example in README to add `await`.

## 0.7.0+1

* Add transactions example to README.

## 0.7.0

* **Breaking change**. `snapshots` is now a method instead of a getter.
* **Breaking change**. `setData` uses named arguments instead of `SetOptions`.

## 0.6.3

* Updated Google Play Services dependencies to version 15.0.0.

## 0.6.2

* Support for BLOB data type.

## 0.6.1

* Simplified podspec for Cocoapods 1.5.0, avoiding link issues in app archives.

## 0.6.0

* **Breaking change**. Renamed 'getCollection()' to 'collection().'

## 0.5.1

* Expose the Firebase app corresponding to a Firestore
* Expose a constructor for a Firestore with a non-default Firebase app

## 0.5.0

* **Breaking change**. Move path getter to CollectionReference
* Add id getter to CollectionReference

## 0.4.0

* **Breaking change**. Hide Firestore codec class from public API.
* Adjusted Flutter SDK constraint to match Flutter release with extensible
  platform message codec, required already by version 0.3.1.
* Move each class into separate files

## 0.3.2

* Support for batched writes.

## 0.3.1

* Add GeoPoint class
* Allow for reading and writing DocumentReference, DateTime, and GeoPoint
  values from and to Documents.

## 0.3.0

* **Breaking change**. Set SDK constraints to match the Flutter beta release.

## 0.2.12

* Fix handling of `null` document snapshots (document not exists).
* Add `DocumentSnapshot.exists`.

## 0.2.11
* Fix Dart 2 type errors.

## 0.2.10
* Fix Dart 2 type errors.

## 0.2.9
* Relax sdk upper bound constraint to  '<2.0.0' to allow 'edge' dart sdk use.

## 0.2.8
* Support for Query.getDocuments

## 0.2.7

* Add transaction support.

## 0.2.6

* Build fixes for iOS
* Null checking in newly added Query methods

## 0.2.5

* Query can now have more than one orderBy field.
* startAt, startAfter, endAt, and endBefore support
* limit support

## 0.2.4

* Support for DocumentReference.documentID
* Support for CollectionReference.add

## 0.2.3

* Simplified and upgraded Android project template to Android SDK 27.
* Updated package description.

## 0.2.2

* Add `get` to DocumentReference.

## 0.2.1

* Fix bug on Android where removeListener is sometimes called without a handle

## 0.2.0

* **Breaking change**. Upgraded to Gradle 4.1 and Android Studio Gradle plugin
  3.0.1. Older Flutter projects need to upgrade their Gradle setup as well in
  order to use this version of the plugin. Instructions can be found
  [here](https://github.com/flutter/flutter/wiki/Updating-Flutter-projects-to-Gradle-4.1-and-Android-Studio-Gradle-plugin-3.0.1).
* Relaxed GMS dependency to [11.4.0,12.0[

## 0.1.2

* Support for `DocumentReference` update and merge writes
* Suppress unchecked warnings and package name warnings on Android

## 0.1.1

* Added FLT prefix to iOS types.

## 0.1.0

* Added reference to DocumentSnapshot
* Breaking: removed path from DocumentSnapshot
* Additional test coverage for reading collections and documents
* Fixed typo in DocumentChange documentation

## 0.0.6

* Support for getCollection

## 0.0.5

* Support `isNull` filtering in `Query.where`
* Fixed `DocumentChange.oldIndex` and `DocumentChange.newIndex` to be signed
  integers (iOS)

## 0.0.4

* Support for where clauses
* Support for deletion

## 0.0.3

* Renamed package to cloud_firestore

## 0.0.2

* Add path property to DocumentSnapshot

## 0.0.1+1

* Update project homepage

## 0.0.1

* Initial Release
