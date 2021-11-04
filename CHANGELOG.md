# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

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
