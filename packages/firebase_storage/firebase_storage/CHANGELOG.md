## 5.0.0-dev.4

 - **FEAT**: bump compileSdkVersion to 29 (#3975).
 - **FEAT**: update Firebase iOS SDK version to 6.33.0 (from 6.26.0).

## 5.0.0-dev.3

 - **FEAT**: rework (#3612).
 - **DOCS**: README updates (#3768).
 - **CHORE**: delete package_config.json (#3744).

## 5.0.0-dev.2

 - **FIX**: if custom metadata value returns null put value as empty string.

## 5.0.0-dev.1

As part of our on-going work for [#2582](https://github.com/FirebaseExtended/flutterfire/issues/2582) this is our Firebase Storage rework changes.

Overall, Firebase Storage has been heavily reworked to bring it inline with the federated plugin setup along with adding new features,
documentation and many more unit and end-to-end tests (tested on Android, iOS & MacOS).

- **`FirebaseStorage`**

  - **DEPRECATED**: Constructing an instance is now deprecated, use `FirebaseStorage.instanceFor` or `FirebaseStorage.instance` instead.
  - **DEPRECATED**: `getReferenceFromUrl()` is deprecated in favor of calling `ref()` with a path.
  - **DEPRECATED**: `getMaxOperationRetryTimeMillis()` is deprecated in favor of the getter `maxOperationRetryTime`.
  - **DEPRECATED**: `getMaxUploadRetryTimeMillis()` is deprecated in favor of the getter `maxUploadRetryTime`.
  - **DEPRECATED**: `getMaxDownloadRetryTimeMillis()` is deprecated in favor of the getter `maxDownloadRetryTime`.
  - **DEPRECATED**: `setMaxOperationRetryTimeMillis()` is deprecated in favor of `setMaxUploadRetryTime()`.
  - **DEPRECATED**: `setMaxUploadRetryTimeMillis()` is deprecated in favor of `setMaxUploadRetryTime()`.
  - **DEPRECATED**: `setMaxDownloadRetryTimeMillis()` is deprecated in favor of `setMaxDownloadRetryTime()`.
  - **NEW**: To match the Web SDK, calling `ref()` creates a new `Reference` at the bucket root, whereas an optional path (`ref('/foo/bar.png')`) can be used to create a `Reference` pointing at a specific location.
  - **NEW**: Added support for `refFromURL`, which accepts a Google Storage (`gs://`) or HTTP URL and returns a `Reference` synchronously.

- **`Reference`**
  - **BREAKING**: `StorageReference` has been renamed to `Reference`.
  - **DEPRECATED**: `getParent()` is deprecated in favor of `.parent`.
  - **DEPRECATED**: `getRoot()` is deprecated in favor of `.root`.
  - **DEPRECATED**: `getStorage()` is deprecated in favor of `.storage`.
  - **DEPRECATED**: `getBucket()` is deprecated in favor of `.bucket`.
  - **DEPRECATED**: `getPath()` is deprecated in favor of `.fullPath`.
  - **DEPRECATED**: `getName()` is deprecated in favor of `.name`.
  - **NEW**: Added support for `list(options)`.
    - Includes `ListOptions` API (see below).
  - **NEW**: Added support for `listAll()`.
  - **NEW**: `putString()` has been added to accept a string value, of type Base64, Base64Url, a [Data URL](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/Data_URIs) or raw strings.
    - Data URLs automatically set the `Content-Type` metadata if not already set.
  - **NEW**: `getData()` does not require a `maxSize`, it can now be called with a default of 10mb.

- **NEW `ListOptions`**
  - The `list()` method accepts a `ListOptions` instance with the following arguments:
    - `maxResults`: limits the number of results returned from a call. Defaults to 1000.
    - `pageToken`: a page token returned from a `ListResult` - used if there are more items to query.

- **NEW `ListResult`**
  - A `ListResult` class has been added, which is returned from a call to `list()` or `listAll()`. It exposes the following properties:
    - `items` (`List<Reference>`): Returns the list of reference objects at the current reference location.
    - `prefixes` (`List<Reference>`): Returns the list of reference sub-folders at the current reference location.
    - `nextPageToken` (`String`): Returns a string (or null) if a next page during a `list()` call exists.

- **Tasks**
  - Tasks have been overhauled to be closer to the expected Firebase Web SDK Storage API, allowing users to access and control on-going tasks easier. There are a number of breaking changes & features with this overhaul:
    - **BREAKING**: `StorageUploadTask` has been renamed to `UploadTask` (extends `Task`).
    - **BREAKING**: `StorageDownloadTask` has been renamed to `DownloadTask` (extends `Task`).
    - **BREAKING**: `StorageTaskEvent` has been removed (see below).
    - **BREAKING**: `StorageTaskSnapshot` has been renamed to `TaskSnapshot`.
    - **BREAKING**: `pause()`, `cancel()` and `resume()` are now Futures which return a boolean value to represent whether the status update was successful.
      - Previously, these were `void` methods but still carried out an asynchronous tasks, potentially leading to uncaught exceptions.
    - **BREAKING**: `isCanceled`, `isComplete`, `isInProgress`, `isPaused` and `isSuccessful` have now been removed. Instead, you should subscribe to the stream (for paused/progress/complete/error events) or the task `Future` for task completion/errors.
     - Additionally the latest `TaskSnapshot` now provides the latest `TaskState` via `task.snapshot.state`.
    - **BREAKING**: The `events` stream (now `snapshotEvents`) previously returned a `StorageTaskEvent`, containing a `StorageTaskEventType` and `StorageTaskSnapshot` Instead, the stream now returns a `TaskSnapshot` which includes the `state`.
    - **BREAKING**: A task failure and cancellation now throw a `FirebaseException` instead of a new event.
    - **DEPRECATED**: `events` stream is deprecated in favor of `snapshotEvents`.
    - **DEPRECATED**: `lastSnapshot` is deprecated in favor of `snapshot`.

#### Example

The new Tasks API matches the Web SDK API, for example:

```dart
UploadTask task = FirebaseStorage.instance.ref('/notes.text').putString('My notes!');

// Optional
task.snapshotEvents.listen((TaskSnapshot snapshot) {
  print('Snapshot state: ${snapshot.state}'); // paused, running, complete
  print('Progress: ${snapshot.totalBytes / snapshot.bytesTransferred}');
}, onError: (Object e) {
  print(e); // FirebaseException
});

// Optional
task
  .then((TaskSnapshot snapshot) {
    print('Upload complete!');
  })
  .catchError((Object e) {
    print(e); // FirebaseException
  });
```

Subscribing to Stream updates and/or the tasks delegating Future is optional - if you require progress updates on your task use the Stream, otherwise
the Future will resolve once its complete. Using both together is also supported.

## 4.0.0

* Depend on `firebase_core`.
* Firebase iOS SDK versions are now locked to use the same version defined in `firebase_core`.
* Firebase Android SDK versions are now using the Firebase Bill of Materials (BoM) to specify individual SDK versions. BoM version is also sourced from `firebase_core`.
* Allow iOS & MacOS plugins to be imported as modules.

## 3.1.6

* Update lower bound of dart dependency to 2.0.0.

## 3.1.5

* Add macOS support

## 3.1.4

* Fix for missing UserAgent.h compilation failures.

## 3.1.3

* Replace deprecated `getFlutterEngine` call on Android.

## 3.1.2

* Make the pedantic dev_dependency explicit.

## 3.1.1

* Removed unnecessary debug print statements ("i am working").

## 3.1.0

* Added error handling to `StorageFileDownloadTask` and added propagation of errors to the Future returned by the `writeToFile` method in `StorageReference`.
* Added unit tests for writeToFile.
* Updated integration test in example to use proper error handling.

## 3.0.11

* Remove the deprecated `author:` field from pubspec.yaml
* Migrate the plugin to the pubspec platforms manifest.
* Bump the minimum Flutter version to 1.10.0.

## 3.0.10

* Fix example app by adding a call to `ensureInitialized`.

## 3.0.9

* Support the v2 Android embedding.

## 3.0.8

* Updated README instructions for contributing for consistency with other Flutterfire plugins.

## 3.0.7

* Remove AndroidX warning.

## 3.0.6

* Update documentation to reflect new repository location.
* Update unit tests to call `TestWidgetsFlutterBinding.ensureInitialized`.
* Remove executable bit on LICENSE file.

## 3.0.5

* Removed automatic print statements for `StorageTaskEvent`'s.
  If you want to see the event status in your logs now, you will have to use the following:
  `storageReference.put{File/Data}(..).events.listen((event) => print('EVENT ${event.type}'));`
* Updated `README.md` to explain the above.

## 3.0.4

* Update google-services Android gradle plugin to 4.3.0 in documentation and examples.

## 3.0.3

* Fix inconsistency of `getPath`, on Android the path returned started with a `/` but on iOS it did not
* Fix content-type auto-detection on Android

## 3.0.2

* Automatically use version from pubspec.yaml when reporting usage to Firebase.

## 3.0.1

* Add missing template type parameter to `invokeMethod` calls.
* Bump minimum Flutter version to 1.5.0.
* Replace invokeMethod with invokeMapMethod wherever necessary.

## 3.0.0

* Update Android dependencies to latest.

## 2.1.1+2

* On iOS, use `putFile` instead of `putData` appropriately to detect `Content-Type`.

## 2.1.1+1

* On iOS, gracefully handle the case of uploading a nonexistent file without crashing.

## 2.1.1

* Added integration tests.

## 2.1.0+1

* Reverting error.code casting/formatting to what it was until version 2.0.1.

## 2.1.0

* Added support for getReferenceFromUrl.

## 2.0.1+2

* Log messages about automatic configuration of the default app are now less confusing.

## 2.0.1+1

* Remove categories.

## 2.0.1

* Log a more detailed warning at build time about the previous AndroidX
  migration.

## 2.0.0

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

  This was originally incorrectly pushed in the `1.1.0` update.

## 1.1.0+1

* **Revert the breaking 1.1.0 update**. 1.1.0 was known to be breaking and
  should have incremented the major version number instead of the minor. This
  revert is in and of itself breaking for anyone that has already migrated
  however. Anyone who has already migrated their app to AndroidX should
  immediately update to `2.0.0` instead. That's the correctly versioned new push
  of `1.1.0`.

## 1.1.0

* **BAD**. This was a breaking change that was incorrectly published on a minor
  version upgrade, should never have happened. Reverted by 1.1.0+1.

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

## 1.0.4

* Bump Android dependencies to latest.

## 1.0.3

* Added monitoring of StorageUploadTask via `events` stream.
* Added support for StorageUploadTask functions: `pause`, `resume`, `cancel`.
* Set http version to be compatible with flutter_test.

## 1.0.2

* Added missing http package dependency.

## 1.0.1

* Bump Android and Firebase dependency versions.

## 1.0.0

* **Breaking change**. Make StorageUploadTask implementation classes private.
* Bump to released version

## 0.3.7

* Updated Gradle tooling to match Android Studio 3.1.2.

## 0.3.6

* Added support for custom metadata.

## 0.3.5

* Updated iOS implementation to reflect Firebase API changes.

## 0.3.4

* Added timeout properties to FirebaseStorage.

## 0.3.3

* Added support for initialization with a custom Firebase app.

## 0.3.2

* Added support for StorageReference `writeToFile`.

## 0.3.1

* Added support for StorageReference functions: `getParent`, `getRoot`, `getStorage`, `getName`, `getPath`, `getBucket`.

## 0.3.0

* **Breaking change**. Changed StorageUploadTask to abstract, removed the 'file' field, and made 'path' and 'metadata'
  private. Added two subclasses: StorageFileUploadTask and StorageDataUploadTask.
* Deprecated the `put` function and added `putFile` and `putData` to upload files and bytes respectively.

## 0.2.6

* Added support for updateMetadata.

## 0.2.5

* Added StorageMetadata class, support for getMetadata, and support for uploading file with metadata.

## 0.2.4

* Updated Google Play Services dependencies to version 15.0.0.

## 0.2.3

* Updated package channel name and made channel visible for testing

## 0.2.2

* Simplified podspec for Cocoapods 1.5.0, avoiding link issues in app archives.

## 0.2.1

* Added support for getDownloadUrl.

## 0.2.0

* **Breaking change**. Set SDK constraints to match the Flutter beta release.

## 0.1.5

* Fix Dart 2 type errors.

## 0.1.4

* Enabled use in Swift projects.

## 0.1.3

* Added StorageReference `path` getter to retrieve the path component for the storage node.

## 0.1.2

* Added StorageReference delete function to remove files from Firebase.

## 0.1.1

* Simplified and upgraded Android project template to Android SDK 27.
* Updated package description.

## 0.1.0

* **Breaking change**. Upgraded to Gradle 4.1 and Android Studio Gradle plugin
  3.0.1. Older Flutter projects need to upgrade their Gradle setup as well in
  order to use this version of the plugin. Instructions can be found
  [here](https://github.com/flutter/flutter/wiki/Updating-Flutter-projects-to-Gradle-4.1-and-Android-Studio-Gradle-plugin-3.0.1).
* Relaxed GMS dependency to [11.4.0,12.0[

## 0.0.8

* Added FLT prefix to iOS types
* Change GMS dependency to 11.4.+

## 0.0.7

* Change GMS dependency to 11.+

## 0.0.6

* Added StorageReference getData function to download files into memory.

## 0.0.5+1

* Aligned author name with rest of repo.

## 0.0.5

* Updated to Firebase SDK to always use latest patch version for 11.0.x builds
* Fix crash when encountering upload failure

## 0.0.4

* Updated to Firebase SDK Version 11.0.1

## 0.0.3

* Suppress unchecked warnings

## 0.0.2

* Bumped buildToolsVersion to 25.0.3
* Updated README

## 0.0.1

* Initial Release
