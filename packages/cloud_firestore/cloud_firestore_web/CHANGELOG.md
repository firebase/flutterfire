## 1.0.1

 - **FIX**: Fix wrong cast (FirebaseExtended#5050) (#5242).

## 1.0.0

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 1.0.0-1.0.nullsafety.0

 - Bump "cloud_firestore_web" to `1.0.0-1.0.nullsafety.0`.

## 0.4.0-1.0.nullsafety.2

 - **FIX**: Fixed crashes due to null `Settings` (#5031).

## 0.4.0-1.0.nullsafety.1

 - Update a dependency to the latest release.

## 0.4.0-1.0.nullsafety.0

> Note: This release has breaking changes.

 - **BREAKING** **REFACTOR**: migrate to NNBD (#4780).

## 0.3.0+1

 - Update a dependency to the latest release.

## 0.3.0

> Note: This release has breaking changes.

 - **FIX**: ensure web FieldValue types are converted (#4247).
 - **BREAKING** **REFACTOR**: remove all currently deprecated APIs (#4594).

## 0.2.1+2

 - Update a dependency to the latest release.

## 0.2.1+1

 - Update a dependency to the latest release.

## 0.2.1

 - **FEAT**: migrate firebase interop files to local repository (#3973).
 - **FEAT** [WEB] `FirebaseFirestore.enablePersistence` now accepts `PersistenceSettings`
 - **FEAT** [WEB] adds `PersistenceSettings` class
 - **FEAT** [WEB] adds support for `FirebaseFirestore.clearPersistence`
 - **FEAT** [WEB] adds support for `FirebaseFirestore.terminate`
 - **FEAT** [WEB] adds support for `FirebaseFirestore.waitForPendingWrites`
 - **FEAT** [WEB] adds support for `SetOptions.mergeFields`
 - **FEAT** [WEB] adds `GetOptions` support for querying against server/cache
 - **FEAT** [WEB] adds support for `Query.limitToLast`
 - **FEAT** [WEB] adds support for `FirebaseFirestore.snapshotsInSync`

## 0.2.0+5

 - Update a dependency to the latest release.

## 0.2.0+4

 - **FIX**: bubble exceptions (#3701).
 - **FIX**: fix returning of transaction result (#3747).
 - **FIX**: ensure isCollectionGroupQuery is initialised (#3772).

## 0.2.0+3

 - **FIX**: dependency issue in pubspec.yaml (#3734).

## 0.2.0+2

 - **FIX**: fix dependency in pubspec.yaml (#3713).

## 0.2.0+1

* Fixed issue #3210 (`Query.orderBy(FieldPath.documentId)` throws exception).
* Bump `cloud_firestore_platform_interface` dependency.

## 0.2.0

* See `cloud_firestore` plugin changelog.

## 0.1.1+2

* Ensure QueryWeb correctly encodes values passed in to `[start|end][At|Before](Document?)` methods.

## 0.1.1+1

* Ensure FieldValueFactoryWeb correctly encodes parameters for arrayRemove/arrayUnion FieldValues.

## 0.1.1

* Support equality comparison of field values.
* `FieldValueWeb` no longer extends `FieldValuePlatform`.
* Updated platform interface dependency.

## 0.1.0+4

* Make the pedantic dev_dependency explicit.

## 0.1.0+3

- Removed unit test that was only testing dart-lang behavior.

## 0.1.0+2

- Update documentation about this package being the endorsed platform for web.

## 0.1.0+1

- Fix `fileName` prop in pubspec.yaml

## 0.1.0

- Initial release
