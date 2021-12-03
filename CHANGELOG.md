# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## 2021-12-02

### Changes

---

Packages with breaking changes:

- There are no breaking changes in this release.

Packages with other changes:

- [`cloud_firestore` - `v3.1.1`](#cloud_firestore---v311)
- [`cloud_firestore_web` - `v2.6.0`](#cloud_firestore_web---v260)
- [`cloud_functions` - `v3.2.0`](#cloud_functions---v320)
- [`cloud_functions_web` - `v4.2.0`](#cloud_functions_web---v420)
- [`firebase_analytics` - `v9.0.0-dev.4`](#firebase_analytics---v900-dev4)
- [`firebase_analytics_web` - `v0.4.0-dev.4`](#firebase_analytics_web---v040-dev4)
- [`firebase_app_check` - `v0.0.4`](#firebase_app_check---v004)
- [`firebase_app_check_web` - `v0.0.3`](#firebase_app_check_web---v003)
- [`firebase_auth` - `v3.3.0`](#firebase_auth---v330)
- [`firebase_auth_web` - `v3.3.0`](#firebase_auth_web---v330)
- [`firebase_core` - `v1.10.1`](#firebase_core---v1101)
- [`firebase_core_platform_interface` - `v4.2.0`](#firebase_core_platform_interface---v420)
- [`firebase_core_web` - `v1.3.0`](#firebase_core_web---v130)
- [`firebase_crashlytics` - `v2.4.0`](#firebase_crashlytics---v240)
- [`firebase_database` - `v8.2.0`](#firebase_database---v820)
- [`firebase_database_web` - `v0.1.2`](#firebase_database_web---v012)
- [`firebase_messaging` - `v11.2.0`](#firebase_messaging---v1120)
- [`firebase_messaging_platform_interface` - `v3.1.0`](#firebase_messaging_platform_interface---v310)
- [`firebase_messaging_web` - `v2.2.0`](#firebase_messaging_web---v220)
- [`firebase_performance_web` - `v0.0.3`](#firebase_performance_web---v003)
- [`firebase_remote_config` - `v1.0.0-dev.3`](#firebase_remote_config---v100-dev3)
- [`firebase_remote_config_web` - `v1.0.0-dev.3`](#firebase_remote_config_web---v100-dev3)
- [`firebase_storage` - `v10.2.0`](#firebase_storage---v1020)
- [`firebase_storage_web` - `v3.2.0`](#firebase_storage_web---v320)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

- `firebase_in_app_messaging` - `v0.5.0+14`
- `firebase_auth_platform_interface` - `v6.1.5`
- `firebase_crashlytics_platform_interface` - `v3.1.7`
- `firebase_remote_config_platform_interface` - `v1.0.0-dev.3`
- `firebase_database_platform_interface` - `v0.1.0+4`
- `firebase_dynamic_links` - `v3.0.2`
- `cloud_firestore_platform_interface` - `v5.4.6`
- `firebase_analytics_platform_interface` - `v3.0.0-dev.4`
- `firebase_app_check_platform_interface` - `v0.0.1+10`
- `cloud_functions_platform_interface` - `v5.0.15`
- `firebase_storage_platform_interface` - `v4.0.7`
- `firebase_performance_platform_interface` - `v0.0.1+8`
- `firebase_performance` - `v0.7.1+5`

---

#### `cloud_firestore` - `v3.1.1`

 - **REFACTOR**: migrate remaining examples & e2e tests to null-safety (#7393).
 - **FIX**: suppress Java unchecked cast lint warning in Android plugin (#7431).

#### `cloud_firestore_web` - `v2.6.0`

 - **FEAT**: automatically inject Firebase JS SDKs (#7359).

#### `cloud_functions` - `v3.2.0`

 - **REFACTOR**: migrate remaining examples & e2e tests to null-safety (#7393).
 - **FEAT**: automatically inject Firebase JS SDKs (#7359).

#### `cloud_functions_web` - `v4.2.0`

 - **FEAT**: automatically inject Firebase JS SDKs (#7359).

#### `firebase_analytics` - `v9.0.0-dev.4`

 - **FEAT**: automatically inject Firebase JS SDKs (#7359).

#### `firebase_analytics_web` - `v0.4.0-dev.4`

 - **FEAT**: automatically inject Firebase JS SDKs (#7359).

#### `firebase_app_check` - `v0.0.4`

 - **REFACTOR**: migrate remaining examples & e2e tests to null-safety (#7393).
 - **FEAT**: automatically inject Firebase JS SDKs (#7359).

#### `firebase_app_check_web` - `v0.0.3`

 - **FEAT**: automatically inject Firebase JS SDKs (#7359).

#### `firebase_auth` - `v3.3.0`

 - **REFACTOR**: migrate remaining examples & e2e tests to null-safety (#7393).
 - **FEAT**: automatically inject Firebase JS SDKs (#7359).

#### `firebase_auth_web` - `v3.3.0`

 - **FEAT**: automatically inject Firebase JS SDKs (#7359).

#### `firebase_core` - `v1.10.1`

 - **REFACTOR**: migrate remaining examples & e2e tests to null-safety (#7393).

#### `firebase_core_platform_interface` - `v4.2.0`

 - **FEAT**: auto inject Firebase scripts (#7358).

#### `firebase_core_web` - `v1.3.0`

 - **FEAT**: automatically inject Firebase JS SDKs (#7359).
 - **FEAT**: auto inject Firebase scripts (#7358).

#### `firebase_crashlytics` - `v2.4.0`

 - **REFACTOR**: migrate remaining examples & e2e tests to null-safety (#7393).
 - **FEAT**: log development platform to Crashlytics in Crashlytics iOS plugin (#7322).

#### `firebase_database` - `v8.2.0`

 - **FEAT**: automatically inject Firebase JS SDKs (#7359).

#### `firebase_database_web` - `v0.1.2`

 - **FEAT**: automatically inject Firebase JS SDKs (#7359).

#### `firebase_messaging` - `v11.2.0`

 - **REFACTOR**: migrate remaining examples & e2e tests to null-safety (#7393).
 - **FEAT**: automatically inject Firebase JS SDKs (#7359).

#### `firebase_messaging_platform_interface` - `v3.1.0`

 - **FEAT**: add support for `RemoteMessage` on web (#7430).

#### `firebase_messaging_web` - `v2.2.0`

 - **FEAT**: automatically inject Firebase JS SDKs (#7359).

#### `firebase_performance_web` - `v0.0.3`

 - **FEAT**: automatically inject Firebase JS SDKs (#7359).

#### `firebase_remote_config` - `v1.0.0-dev.3`

 - **REFACTOR**: migrate remaining examples & e2e tests to null-safety (#7393).
 - **FEAT**: automatically inject Firebase JS SDKs (#7359).

#### `firebase_remote_config_web` - `v1.0.0-dev.3`

 - **FEAT**: automatically inject Firebase JS SDKs (#7359).

#### `firebase_storage` - `v10.2.0`

 - **REFACTOR**: migrate remaining examples & e2e tests to null-safety (#7393).
 - **FEAT**: automatically inject Firebase JS SDKs (#7359).

#### `firebase_storage_web` - `v3.2.0`

 - **FEAT**: automatically inject Firebase JS SDKs (#7359).


## 2021-11-09

### Changes

---

Packages with breaking changes:

- There are no breaking changes in this release.

Packages with other changes:

- [`cloud_functions_web` - `v4.1.1`](#cloud_functions_web---v411)
- [`firebase_analytics` - `v9.0.0-dev.3`](#firebase_analytics---v900-dev3)
- [`firebase_analytics_platform_interface` - `v3.0.0-dev.3`](#firebase_analytics_platform_interface---v300-dev3)
- [`firebase_analytics_web` - `v0.4.0-dev.3`](#firebase_analytics_web---v040-dev3)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

- `cloud_functions` - `v3.1.1`

---

#### `cloud_functions_web` - `v4.1.1`

 - **FIX**: correctly pass `region` to JS functions interop instance (#7328).

#### `firebase_analytics` - `v9.0.0-dev.3`

 - **FEAT**: add macOS support (#7313).

#### `firebase_analytics_platform_interface` - `v3.0.0-dev.3`

 - **FEAT**: add macOS support (#7313).

#### `firebase_analytics_web` - `v0.4.0-dev.3`

 - **FEAT**: add macOS support (#7313).


## 2021-11-06

### Changes

---

Packages with breaking changes:

- There are no breaking changes in this release.

Packages with other changes:

- [`cloud_firestore` - `v3.1.0`](#cloud_firestore---v310)
- [`cloud_firestore_web` - `v2.5.0`](#cloud_firestore_web---v250)
- [`cloud_functions` - `v3.1.0`](#cloud_functions---v310)
- [`cloud_functions_web` - `v4.1.0`](#cloud_functions_web---v410)
- [`firebase_analytics` - `v9.0.0-dev.2`](#firebase_analytics---v900-dev2)
- [`firebase_analytics_web` - `v0.4.0-dev.2`](#firebase_analytics_web---v040-dev2)
- [`firebase_app_check` - `v0.0.3`](#firebase_app_check---v003)
- [`firebase_app_check_web` - `v0.0.2`](#firebase_app_check_web---v002)
- [`firebase_auth` - `v3.2.0`](#firebase_auth---v320)
- [`firebase_auth_web` - `v3.2.0`](#firebase_auth_web---v320)
- [`firebase_core` - `v1.10.0`](#firebase_core---v1100)
- [`firebase_core_platform_interface` - `v4.1.0`](#firebase_core_platform_interface---v410)
- [`firebase_core_web` - `v1.2.0`](#firebase_core_web---v120)
- [`firebase_crashlytics` - `v2.3.0`](#firebase_crashlytics---v230)
- [`firebase_database` - `v8.1.0`](#firebase_database---v810)
- [`firebase_database_web` - `v0.1.1`](#firebase_database_web---v011)
- [`firebase_messaging` - `v11.1.0`](#firebase_messaging---v1110)
- [`firebase_messaging_web` - `v2.1.0`](#firebase_messaging_web---v210)
- [`firebase_performance_web` - `v0.0.2`](#firebase_performance_web---v002)
- [`firebase_remote_config` - `v1.0.0-dev.2`](#firebase_remote_config---v100-dev2)
- [`firebase_remote_config_web` - `v1.0.0-dev.2`](#firebase_remote_config_web---v100-dev2)
- [`firebase_storage` - `v10.1.0`](#firebase_storage---v1010)
- [`firebase_storage_web` - `v3.1.0`](#firebase_storage_web---v310)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

- `firebase_in_app_messaging` - `v0.5.0+13`
- `firebase_crashlytics_platform_interface` - `v3.1.6`
- `firebase_auth_platform_interface` - `v6.1.4`
- `firebase_remote_config_platform_interface` - `v1.0.0-dev.2`
- `firebase_database_platform_interface` - `v0.1.0+3`
- `firebase_dynamic_links` - `v3.0.1`
- `cloud_firestore_platform_interface` - `v5.4.5`
- `firebase_messaging_platform_interface` - `v3.0.9`
- `firebase_analytics_platform_interface` - `v3.0.0-dev.2`
- `firebase_app_check_platform_interface` - `v0.0.1+9`
- `cloud_functions_platform_interface` - `v5.0.14`
- `firebase_storage_platform_interface` - `v4.0.6`
- `firebase_performance_platform_interface` - `v0.0.1+7`
- `firebase_performance` - `v0.7.1+4`

---

#### `cloud_firestore` - `v3.1.0`

 - **FEAT**: support initializing default `FirebaseApp` instances from Dart (#6549).

#### `cloud_firestore_web` - `v2.5.0`

 - **FEAT**: support initializing default `FirebaseApp` instances from Dart (#6549).

#### `cloud_functions` - `v3.1.0`

 - **FEAT**: support initializing default `FirebaseApp` instances from Dart (#6549).

#### `cloud_functions_web` - `v4.1.0`

 - **FEAT**: support initializing default `FirebaseApp` instances from Dart (#6549).

#### `firebase_analytics` - `v9.0.0-dev.2`

 - **FEAT**: support initializing default `FirebaseApp` instances from Dart (#6549).

#### `firebase_analytics_web` - `v0.4.0-dev.2`

 - **FEAT**: support initializing default `FirebaseApp` instances from Dart (#6549).

#### `firebase_app_check` - `v0.0.3`

 - **FEAT**: support initializing default `FirebaseApp` instances from Dart (#6549).

#### `firebase_app_check_web` - `v0.0.2`

 - **FEAT**: support initializing default `FirebaseApp` instances from Dart (#6549).

#### `firebase_auth` - `v3.2.0`

 - **FEAT**: support initializing default `FirebaseApp` instances from Dart (#6549).

#### `firebase_auth_web` - `v3.2.0`

 - **FEAT**: support initializing default `FirebaseApp` instances from Dart (#6549).

#### `firebase_core` - `v1.10.0`

 - **FEAT**: support initializing default `FirebaseApp` instances from Dart (#6549).

#### `firebase_core_platform_interface` - `v4.1.0`

 - **FEAT**: support initializing default `FirebaseApp` instances from Dart (#6549).

#### `firebase_core_web` - `v1.2.0`

 - **FEAT**: support initializing default `FirebaseApp` instances from Dart (#6549).

#### `firebase_crashlytics` - `v2.3.0`

 - **FEAT**: support initializing default `FirebaseApp` instances from Dart (#6549).

#### `firebase_database` - `v8.1.0`

 - **FEAT**: support initializing default `FirebaseApp` instances from Dart (#6549).

#### `firebase_database_web` - `v0.1.1`

 - **FEAT**: support initializing default `FirebaseApp` instances from Dart (#6549).

#### `firebase_messaging` - `v11.1.0`

 - **FEAT**: support initializing default `FirebaseApp` instances from Dart (#6549).

#### `firebase_messaging_web` - `v2.1.0`

 - **FEAT**: support initializing default `FirebaseApp` instances from Dart (#6549).

#### `firebase_performance_web` - `v0.0.2`

 - **FEAT**: support initializing default `FirebaseApp` instances from Dart (#6549).

#### `firebase_remote_config` - `v1.0.0-dev.2`

 - **FEAT**: support initializing default `FirebaseApp` instances from Dart (#6549).

#### `firebase_remote_config_web` - `v1.0.0-dev.2`

 - **FEAT**: support initializing default `FirebaseApp` instances from Dart (#6549).

#### `firebase_storage` - `v10.1.0`

 - **FEAT**: support initializing default `FirebaseApp` instances from Dart (#6549).

#### `firebase_storage_web` - `v3.1.0`

 - **FEAT**: support initializing default `FirebaseApp` instances from Dart (#6549).


## 2021-11-04

### Changes

---

Packages with breaking changes:

- [`cloud_firestore` - `v3.0.0`](#cloud_firestore---v300)
- [`firebase_dynamic_links` - `v3.0.0`](#firebase_dynamic_links---v300)
- [`firebase_messaging` - `v11.0.0`](#firebase_messaging---v1100)

Packages with other changes:

- [`firebase_core` - `v1.9.0`](#firebase_core---v190)
- [`firebase_in_app_messaging` - `v0.5.0+12`](#firebase_in_app_messaging---v05012)
- [`firebase_messaging_platform_interface` - `v3.0.8`](#firebase_messaging_platform_interface---v308)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

- `firebase_crashlytics` - `v2.2.5`
- `firebase_crashlytics_platform_interface` - `v3.1.5`
- `firebase_auth` - `v3.1.5`
- `firebase_auth_web` - `v3.1.4`
- `firebase_auth_platform_interface` - `v6.1.3`
- `firebase_remote_config` - `v1.0.0-dev.1`
- `firebase_remote_config_web` - `v1.0.0-dev.1`
- `firebase_remote_config_platform_interface` - `v1.0.0-dev.1`
- `firebase_database_web` - `v0.1.0+2`
- `firebase_database` - `v8.0.2`
- `firebase_database_platform_interface` - `v0.1.0+2`
- `cloud_firestore_web` - `v2.4.5`
- `cloud_firestore_platform_interface` - `v5.4.4`
- `firebase_messaging_web` - `v2.0.8`
- `firebase_analytics_platform_interface` - `v3.0.0-dev.1`
- `firebase_analytics` - `v9.0.0-dev.1`
- `firebase_analytics_web` - `v0.4.0-dev.1`
- `firebase_app_check_platform_interface` - `v0.0.1+8`
- `firebase_app_check` - `v0.0.2+4`
- `firebase_app_check_web` - `v0.0.1+8`
- `cloud_functions_web` - `v4.0.15`
- `cloud_functions` - `v3.0.6`
- `cloud_functions_platform_interface` - `v5.0.13`
- `firebase_storage_web` - `v3.0.5`
- `firebase_storage_platform_interface` - `v4.0.5`
- `firebase_storage` - `v10.0.7`
- `firebase_performance_platform_interface` - `v0.0.1+6`
- `firebase_performance` - `v0.7.1+3`

---

#### `cloud_firestore` - `v3.0.0`

- **BREAKING** **FEAT**: update Android `minSdk` version to 19 as this is required by Firebase Android SDK `29.0.0` (#7298).

#### `firebase_dynamic_links` - `v3.0.0`

- **BREAKING** **FEAT**: update Android `minSdk` version to 19 as this is required by Firebase Android SDK `29.0.0` (#7298).

#### `firebase_in_app_messaging` - `v0.6.0`

- **BREAKING** **REFACTOR**: update Firebase Analytics plugin to match latest Firebase APIs (#7032).

#### `firebase_messaging` - `v11.0.0`

- **FIX**: Add Android implementation to get notification permissions (#7168).
- **BREAKING** **FEAT**: update Android `minSdk` version to 19 as this is required by Firebase Android SDK `29.0.0` (#7298).

#### `firebase_core` - `v1.9.0`

- **FEAT**: bump Firebase Android SDK version to `29.0.0` (#7296).
- **FEAT**: bump Firebase iOS SDK to `8.9.0` (#7289).

#### `firebase_in_app_messaging` - `v0.5.0+12`

- **REFACTOR**: update example app to use latest Firebase Analytics plugin APIs.

#### `firebase_messaging_platform_interface` - `v3.0.8`

- **FIX**: Add Android implementation to get notification permissions (#7168).


## 2021-10-21

### Changes

---

Packages with breaking changes:

- There are no breaking changes in this release.

Packages with other changes:

- [`cloud_firestore` - `v2.5.4`](#cloud_firestore---v254)
- [`cloud_functions` - `v3.0.5`](#cloud_functions---v305)
- [`firebase_analytics` - `v8.3.4`](#firebase_analytics---v834)
- [`firebase_auth` - `v3.1.4`](#firebase_auth---v314)
- [`firebase_core` - `v1.8.0`](#firebase_core---v180)
- [`firebase_crashlytics` - `v2.2.4`](#firebase_crashlytics---v224)
- [`firebase_database` - `v8.0.1`](#firebase_database---v801)
- [`firebase_dynamic_links` - `v2.0.11`](#firebase_dynamic_links---v2011)
- [`firebase_in_app_messaging` - `v0.5.0+11`](#firebase_in_app_messaging---v05011)
- [`firebase_messaging` - `v10.0.9`](#firebase_messaging---v1009)
- [`firebase_performance` - `v0.7.1+2`](#firebase_performance---v0712)
- [`firebase_remote_config` - `v0.11.0+2`](#firebase_remote_config---v01102)
- [`firebase_storage` - `v10.0.6`](#firebase_storage---v1006)

Packages with dependency updates only:

- `firebase_crashlytics_platform_interface` - `v3.1.4`
- `firebase_auth_web` - `v3.1.3`
- `firebase_auth_platform_interface` - `v6.1.2`
- `firebase_remote_config_platform_interface` - `v0.3.0+7`
- `firebase_database_web` - `v0.1.0+1`
- `firebase_database_platform_interface` - `v0.1.0+1`
- `cloud_firestore_web` - `v2.4.4`
- `firebase_messaging_web` - `v2.0.7`
- `cloud_firestore_platform_interface` - `v5.4.3`
- `firebase_messaging_platform_interface` - `v3.0.7`
- `firebase_app_check_platform_interface` - `v0.0.1+7`
- `firebase_app_check` - `v0.0.2+3`
- `firebase_app_check_web` - `v0.0.1+7`
- `cloud_functions_web` - `v4.0.14`
- `cloud_functions_platform_interface` - `v5.0.12`
- `firebase_performance_platform_interface` - `v0.0.1+5`
- `firebase_storage_web` - `v3.0.4`
- `firebase_storage_platform_interface` - `v4.0.4`

----

#### `cloud_firestore` - `v2.5.4`

 - **REFACTOR**: remove deprecated Flutter Android v1 Embedding usages, including in example app (#7147).
 - **STYLE**: macOS & iOS; explicitly include header that defines `TARGET_OS_OSX` (#7116).

#### `cloud_functions` - `v3.0.5`

 - **REFACTOR**: remove deprecated Flutter Android v1 Embedding usages, including in example app (#7158).

#### `firebase_analytics` - `v8.3.4`

 - **REFACTOR**: remove deprecated Flutter Android v1 Embedding usages, including in example app (#7158).

#### `firebase_auth` - `v3.1.4`

 - **REFACTOR**: remove deprecated Flutter Android v1 Embedding usages, including in example app (#7158).
 - **STYLE**: macOS & iOS; explicitly include header that defines `TARGET_OS_OSX` (#7116).

#### `firebase_core` - `v1.8.0`

 - **REFACTOR**: remove deprecated Flutter Android v1 Embedding usages, including in example app (#7158).
 - **FEAT**: Firebase iOS SDK version bumped to `8.8.0` (#7213).
 - **STYLE**: macOS & iOS; explicitly include header that defines `TARGET_OS_OSX` (#7116).

#### `firebase_crashlytics` - `v2.2.4`

 - **REFACTOR**: remove deprecated Flutter Android v1 Embedding usages, including in example app (#7158).

#### `firebase_database` - `v8.0.1`

 - **REFACTOR**: remove deprecated Flutter Android v1 Embedding usages, including in example app (#7158).
 - **FIX**: issue where using `List` values would error on transaction result (#7001).
 - **DOCS**: update README with latest Firebase RTDB YouTube tutorial (#7149).
 - **CHORE**: update Gradle versions used in Android example app (#7054).

#### `firebase_dynamic_links` - `v2.0.11`

 - **REFACTOR**: remove deprecated Flutter Android v1 Embedding usages, including in example app (#7158).

#### `firebase_in_app_messaging` - `v0.5.0+11`

 - **REFACTOR**: remove deprecated Flutter Android v1 Embedding usages, including in example app (#7158).

#### `firebase_messaging` - `v10.0.9`

 - **REFACTOR**: remove deprecated Flutter Android v1 Embedding usages, including in example app (#7158).
 - **FIX**: Fix crash. If intent.getExtras() returns `null`, do not attempt to handle `RemoteMessage` #6759 (#7094).
 - **STYLE**: macOS & iOS; explicitly include header that defines `TARGET_OS_OSX` (#7116).

#### `firebase_performance` - `v0.7.1+2`

 - **REFACTOR**: remove deprecated Flutter Android v1 Embedding usages, including in example app (#7158).
 - **CHORE**: update Gradle versions used in Android example app (#7054).

#### `firebase_remote_config` - `v0.11.0+2`

 - **REFACTOR**: remove deprecated Flutter Android v1 Embedding usages, including in example app (#7158).
 - **STYLE**: macOS & iOS; explicitly include header that defines `TARGET_OS_OSX` (#7116).

#### `firebase_storage` - `v10.0.6`

 - **REFACTOR**: remove deprecated Flutter Android v1 Embedding usages, including in example app (#7158).
 - **STYLE**: macOS & iOS; explicitly include header that defines `TARGET_OS_OSX` (#7116).

### Dependent package version bumps

Packages listed below depend on other packages in this workspace that have had changes above.

Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon.

- `firebase_crashlytics_platform_interface` - `v3.1.4`
- `firebase_auth_web` - `v3.1.3`
- `firebase_auth_platform_interface` - `v6.1.2`
- `firebase_remote_config_platform_interface` - `v0.3.0+7`
- `firebase_database_web` - `v0.1.0+1`
- `firebase_database_platform_interface` - `v0.1.0+1`
- `cloud_firestore_web` - `v2.4.4`
- `firebase_messaging_web` - `v2.0.7`
- `cloud_firestore_platform_interface` - `v5.4.3`
- `firebase_messaging_platform_interface` - `v3.0.7`
- `firebase_app_check_platform_interface` - `v0.0.1+7`
- `firebase_app_check` - `v0.0.2+3`
- `firebase_app_check_web` - `v0.0.1+7`
- `cloud_functions_web` - `v4.0.14`
- `cloud_functions_platform_interface` - `v5.0.12`
- `firebase_performance_platform_interface` - `v0.0.1+5`
- `firebase_storage_web` - `v3.0.4`
- `firebase_storage_platform_interface` - `v4.0.4`
