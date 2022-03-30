# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## 2022-03-15

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`firebase_auth` - `v3.3.11`](#firebase_auth---v3311)
 - [`firebase_dynamic_links_platform_interface` - `v0.2.2+1`](#firebase_dynamic_links_platform_interface---v0221)
 - [`firebase_messaging` - `v11.2.11`](#firebase_messaging---v11211)
 - [`flutterfire_ui` - `v0.3.6+1`](#flutterfire_ui---v0361)
 - [`firebase_dynamic_links` - `v4.1.1`](#firebase_dynamic_links---v411)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flutterfire_ui` - `v0.3.6+1`
 - `firebase_dynamic_links` - `v4.1.1`

---

#### `firebase_auth` - `v3.3.11`

 - **FIX**: Update APN token once auth plugin has been initialized on `iOS`. (#8201). ([ab6239dd](https://github.com/FirebaseExtended/flutterfire/commit/ab6239ddf5cb14211b76bced04ec52203919a57a))

#### `firebase_dynamic_links_platform_interface` - `v0.2.2+1`

 - **FIX**: Properly type cast utmParameters coming from native side. (#8280). ([22bbd807](https://github.com/FirebaseExtended/flutterfire/commit/22bbd807d2b3c3f9d9cc8ba817ccb4da931ae887))

#### `firebase_messaging` - `v11.2.11`

 - **FIX**: Ensure `onMessage` callback is consistently called on `iOS` platform. (#8202). ([54f5555e](https://github.com/FirebaseExtended/flutterfire/commit/54f5555edbedc553df30d7e32747e3b305fbe643))


## 2022-03-10

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`firebase_messaging` - `v11.2.10`](#firebase_messaging---v11210)

---

#### `firebase_messaging` - `v11.2.10`

 - **FIX**: Update notification key to `NSApplicationLaunchUserNotificationKey` for macOS. (#8251). ([46b54ccd](https://github.com/FirebaseExtended/flutterfire/commit/46b54ccd4aee61654e36396b86ed373939569d00))


## 2022-03-10

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`cloud_functions` - `v3.2.10`](#cloud_functions---v3210)
 - [`firebase_auth` - `v3.3.10`](#firebase_auth---v3310)
 - [`firebase_dynamic_links` - `v4.1.0`](#firebase_dynamic_links---v410)
 - [`firebase_dynamic_links_platform_interface` - `v0.2.2`](#firebase_dynamic_links_platform_interface---v022)
 - [`firebase_messaging` - `v11.2.9`](#firebase_messaging---v1129)
 - [`flutterfire_ui` - `v0.3.6`](#flutterfire_ui---v036)

---

#### `cloud_functions` - `v3.2.10`

 - **FIX**: Allow raw data arguments to be passed as data to Cloud Function for `Android` & `iOS`. (#7994). ([8288b811](https://github.com/FirebaseExtended/flutterfire/commit/8288b811f2b82df263a092428905960960e537c6))

#### `firebase_auth` - `v3.3.10`

 - **FIX**: return correct error code for linkWithCredential `provider-already-linked` on Android (#8245). ([ae090719](https://github.com/FirebaseExtended/flutterfire/commit/ae090719ebbb0873cf227f76004feeae9a7d0580))
 - **FIX**: Fixed bug that sets email to `nil` on `iOS` when the `User` has no provider. (#8209). ([fb646438](https://github.com/FirebaseExtended/flutterfire/commit/fb646438f219b0f0f7c6a8c52e2b9daa4afc833e))

#### `firebase_dynamic_links` - `v4.1.0`

 - **FIX**: pass through `utmParameters` on `iOS` and make property on `PendingDynamicLinkData`. (#8232). ([32d06e79](https://github.com/FirebaseExtended/flutterfire/commit/32d06e793b4fc1bc1dad9b9071f94b28c5d477ca))
 - **FEAT**: add additional `longDynamicLink` parameter for creating a short Dynamic Link enabling additional parameters to be appended such as "ofl". (#7796). ([433a08ea](https://github.com/FirebaseExtended/flutterfire/commit/433a08eaacfaabb109a0185a5e494d87f9334d75))

#### `firebase_dynamic_links_platform_interface` - `v0.2.2`

 - **FIX**: pass through `utmParameters` on `iOS` and make property on `PendingDynamicLinkData`. (#8232). ([32d06e79](https://github.com/FirebaseExtended/flutterfire/commit/32d06e793b4fc1bc1dad9b9071f94b28c5d477ca))
 - **FEAT**: add additional `longDynamicLink` parameter for creating a short Dynamic Link enabling additional parameters to be appended such as "ofl". (#7796). ([433a08ea](https://github.com/FirebaseExtended/flutterfire/commit/433a08eaacfaabb109a0185a5e494d87f9334d75))

#### `firebase_messaging` - `v11.2.9`

 - **FIX**: `getInitialMessage` returns notification once & only if pressed for `iOS`. (#7634). ([85739b4c](https://github.com/FirebaseExtended/flutterfire/commit/85739b4cc2f75c6f7017de0e69160fa07477eb1e))

#### `flutterfire_ui` - `v0.3.6`

 - **FEAT**: Add German localization language support (#8195). ([9976d9d6](https://github.com/FirebaseExtended/flutterfire/commit/9976d9d66b870143227b08af068da3bc2efc5411))


## 2022-02-25

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`cloud_firestore` - `v3.1.10`](#cloud_firestore---v3110)
 - [`cloud_firestore_odm` - `v1.0.0-dev.10`](#cloud_firestore_odm---v100-dev10)
 - [`cloud_firestore_odm_generator` - `v1.0.0-dev.10`](#cloud_firestore_odm_generator---v100-dev10)
 - [`cloud_firestore_platform_interface` - `v5.5.1`](#cloud_firestore_platform_interface---v551)
 - [`cloud_firestore_web` - `v2.6.10`](#cloud_firestore_web---v2610)
 - [`cloud_functions` - `v3.2.9`](#cloud_functions---v329)
 - [`cloud_functions_platform_interface` - `v5.1.1`](#cloud_functions_platform_interface---v511)
 - [`cloud_functions_web` - `v4.2.9`](#cloud_functions_web---v429)
 - [`firebase_analytics` - `v9.1.2`](#firebase_analytics---v912)
 - [`firebase_analytics_platform_interface` - `v3.1.1`](#firebase_analytics_platform_interface---v311)
 - [`firebase_analytics_web` - `v0.4.0+8`](#firebase_analytics_web---v0408)
 - [`firebase_app_check` - `v0.0.6+7`](#firebase_app_check---v0067)
 - [`firebase_app_check_platform_interface` - `v0.0.4+1`](#firebase_app_check_platform_interface---v0041)
 - [`firebase_app_check_web` - `v0.0.5+7`](#firebase_app_check_web---v0057)
 - [`firebase_app_installations` - `v0.1.0+8`](#firebase_app_installations---v0108)
 - [`firebase_app_installations_platform_interface` - `v0.1.1+1`](#firebase_app_installations_platform_interface---v0111)
 - [`firebase_app_installations_web` - `v0.1.0+8`](#firebase_app_installations_web---v0108)
 - [`firebase_auth` - `v3.3.9`](#firebase_auth---v339)
 - [`firebase_auth_platform_interface` - `v6.2.1`](#firebase_auth_platform_interface---v621)
 - [`firebase_auth_web` - `v3.3.9`](#firebase_auth_web---v339)
 - [`firebase_core` - `v1.13.1`](#firebase_core---v1131)
 - [`firebase_core_platform_interface` - `v4.2.5`](#firebase_core_platform_interface---v425)
 - [`firebase_core_web` - `v1.6.1`](#firebase_core_web---v161)
 - [`firebase_crashlytics` - `v2.5.3`](#firebase_crashlytics---v253)
 - [`firebase_crashlytics_platform_interface` - `v3.2.1`](#firebase_crashlytics_platform_interface---v321)
 - [`firebase_database` - `v9.0.8`](#firebase_database---v908)
 - [`firebase_database_platform_interface` - `v0.2.1+1`](#firebase_database_platform_interface---v0211)
 - [`firebase_database_web` - `v0.2.0+7`](#firebase_database_web---v0207)
 - [`firebase_dynamic_links` - `v4.0.8`](#firebase_dynamic_links---v408)
 - [`firebase_dynamic_links_platform_interface` - `v0.2.1+1`](#firebase_dynamic_links_platform_interface---v0211)
 - [`firebase_in_app_messaging` - `v0.6.0+9`](#firebase_in_app_messaging---v0609)
 - [`firebase_in_app_messaging_platform_interface` - `v0.2.1+1`](#firebase_in_app_messaging_platform_interface---v0211)
 - [`firebase_messaging` - `v11.2.8`](#firebase_messaging---v1128)
 - [`firebase_messaging_platform_interface` - `v3.2.1`](#firebase_messaging_platform_interface---v321)
 - [`firebase_messaging_web` - `v2.2.9`](#firebase_messaging_web---v229)
 - [`firebase_ml_model_downloader` - `v0.1.0+8`](#firebase_ml_model_downloader---v0108)
 - [`firebase_ml_model_downloader_platform_interface` - `v0.1.1+1`](#firebase_ml_model_downloader_platform_interface---v0111)
 - [`firebase_performance` - `v0.8.0+7`](#firebase_performance---v0807)
 - [`firebase_performance_platform_interface` - `v0.1.1+1`](#firebase_performance_platform_interface---v0111)
 - [`firebase_performance_web` - `v0.1.0+7`](#firebase_performance_web---v0107)
 - [`firebase_remote_config` - `v2.0.2`](#firebase_remote_config---v202)
 - [`firebase_remote_config_platform_interface` - `v1.1.1`](#firebase_remote_config_platform_interface---v111)
 - [`firebase_remote_config_web` - `v1.0.7`](#firebase_remote_config_web---v107)
 - [`firebase_storage` - `v10.2.9`](#firebase_storage---v1029)
 - [`firebase_storage_platform_interface` - `v4.1.1`](#firebase_storage_platform_interface---v411)
 - [`firebase_storage_web` - `v3.2.10`](#firebase_storage_web---v3210)
 - [`flutterfire_ui` - `v0.3.5+1`](#flutterfire_ui---v0351)

---

#### `cloud_firestore` - `v3.1.10`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `cloud_firestore_odm` - `v1.0.0-dev.10`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `cloud_firestore_odm_generator` - `v1.0.0-dev.10`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `cloud_firestore_platform_interface` - `v5.5.1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `cloud_firestore_web` - `v2.6.10`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `cloud_functions` - `v3.2.9`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `cloud_functions_platform_interface` - `v5.1.1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `cloud_functions_web` - `v4.2.9`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_analytics` - `v9.1.2`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_analytics_platform_interface` - `v3.1.1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_analytics_web` - `v0.4.0+8`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_app_check` - `v0.0.6+7`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_app_check_platform_interface` - `v0.0.4+1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_app_check_web` - `v0.0.5+7`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_app_installations` - `v0.1.0+8`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_app_installations_platform_interface` - `v0.1.1+1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_app_installations_web` - `v0.1.0+8`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_auth` - `v3.3.9`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_auth_platform_interface` - `v6.2.1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_auth_web` - `v3.3.9`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_core` - `v1.13.1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_core_platform_interface` - `v4.2.5`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_core_web` - `v1.6.1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_crashlytics` - `v2.5.3`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_crashlytics_platform_interface` - `v3.2.1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_database` - `v9.0.8`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_database_platform_interface` - `v0.2.1+1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_database_web` - `v0.2.0+7`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_dynamic_links` - `v4.0.8`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_dynamic_links_platform_interface` - `v0.2.1+1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_in_app_messaging` - `v0.6.0+9`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_in_app_messaging_platform_interface` - `v0.2.1+1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_messaging` - `v11.2.8`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_messaging_platform_interface` - `v3.2.1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_messaging_web` - `v2.2.9`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_ml_model_downloader` - `v0.1.0+8`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_ml_model_downloader_platform_interface` - `v0.1.1+1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_performance` - `v0.8.0+7`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_performance_platform_interface` - `v0.1.1+1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_performance_web` - `v0.1.0+7`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_remote_config` - `v2.0.2`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_remote_config_platform_interface` - `v1.1.1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_remote_config_web` - `v1.0.7`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_storage` - `v10.2.9`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_storage_platform_interface` - `v4.1.1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_storage_web` - `v3.2.10`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `flutterfire_ui` - `v0.3.5+1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/FirebaseExtended/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))


## 2022-02-24

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`cloud_firestore_odm_generator` - `v1.0.0-dev.9`](#cloud_firestore_odm_generator---v100-dev9)
 - [`cloud_firestore_platform_interface` - `v5.5.0`](#cloud_firestore_platform_interface---v550)
 - [`cloud_functions_platform_interface` - `v5.1.0`](#cloud_functions_platform_interface---v510)
 - [`firebase_analytics` - `v9.1.1`](#firebase_analytics---v911)
 - [`firebase_analytics_platform_interface` - `v3.1.0`](#firebase_analytics_platform_interface---v310)
 - [`firebase_app_check_platform_interface` - `v0.0.4`](#firebase_app_check_platform_interface---v004)
 - [`firebase_app_installations_platform_interface` - `v0.1.1`](#firebase_app_installations_platform_interface---v011)
 - [`firebase_auth_platform_interface` - `v6.2.0`](#firebase_auth_platform_interface---v620)
 - [`firebase_core` - `v1.13.0`](#firebase_core---v1130)
 - [`firebase_core_web` - `v1.6.0`](#firebase_core_web---v160)
 - [`firebase_crashlytics_platform_interface` - `v3.2.0`](#firebase_crashlytics_platform_interface---v320)
 - [`firebase_database_platform_interface` - `v0.2.1`](#firebase_database_platform_interface---v021)
 - [`firebase_dynamic_links_platform_interface` - `v0.2.1`](#firebase_dynamic_links_platform_interface---v021)
 - [`firebase_in_app_messaging_platform_interface` - `v0.2.1`](#firebase_in_app_messaging_platform_interface---v021)
 - [`firebase_messaging` - `v11.2.7`](#firebase_messaging---v1127)
 - [`firebase_messaging_platform_interface` - `v3.2.0`](#firebase_messaging_platform_interface---v320)
 - [`firebase_ml_model_downloader_platform_interface` - `v0.1.1`](#firebase_ml_model_downloader_platform_interface---v011)
 - [`firebase_performance` - `v0.8.0+6`](#firebase_performance---v0806)
 - [`firebase_performance_platform_interface` - `v0.1.1`](#firebase_performance_platform_interface---v011)
 - [`firebase_remote_config` - `v2.0.1`](#firebase_remote_config---v201)
 - [`firebase_remote_config_platform_interface` - `v1.1.0`](#firebase_remote_config_platform_interface---v110)
 - [`firebase_storage_platform_interface` - `v4.1.0`](#firebase_storage_platform_interface---v410)
 - [`flutterfire_ui` - `v0.3.5`](#flutterfire_ui---v035)
 - [`cloud_firestore_web` - `v2.6.9`](#cloud_firestore_web---v269)
 - [`cloud_firestore` - `v3.1.9`](#cloud_firestore---v319)
 - [`cloud_firestore_odm` - `v1.0.0-dev.9`](#cloud_firestore_odm---v100-dev9)
 - [`cloud_functions_web` - `v4.2.8`](#cloud_functions_web---v428)
 - [`cloud_functions` - `v3.2.8`](#cloud_functions---v328)
 - [`firebase_analytics_web` - `v0.4.0+7`](#firebase_analytics_web---v0407)
 - [`firebase_app_check_web` - `v0.0.5+6`](#firebase_app_check_web---v0056)
 - [`firebase_app_check` - `v0.0.6+6`](#firebase_app_check---v0066)
 - [`firebase_app_installations_web` - `v0.1.0+7`](#firebase_app_installations_web---v0107)
 - [`firebase_app_installations` - `v0.1.0+7`](#firebase_app_installations---v0107)
 - [`firebase_auth_web` - `v3.3.8`](#firebase_auth_web---v338)
 - [`firebase_auth` - `v3.3.8`](#firebase_auth---v338)
 - [`firebase_in_app_messaging` - `v0.6.0+8`](#firebase_in_app_messaging---v0608)
 - [`firebase_crashlytics` - `v2.5.2`](#firebase_crashlytics---v252)
 - [`firebase_remote_config_web` - `v1.0.6`](#firebase_remote_config_web---v106)
 - [`firebase_database_web` - `v0.2.0+6`](#firebase_database_web---v0206)
 - [`firebase_database` - `v9.0.7`](#firebase_database---v907)
 - [`firebase_dynamic_links` - `v4.0.7`](#firebase_dynamic_links---v407)
 - [`firebase_messaging_web` - `v2.2.8`](#firebase_messaging_web---v228)
 - [`firebase_ml_model_downloader` - `v0.1.0+7`](#firebase_ml_model_downloader---v0107)
 - [`firebase_storage_web` - `v3.2.9`](#firebase_storage_web---v329)
 - [`firebase_storage` - `v10.2.8`](#firebase_storage---v1028)
 - [`firebase_performance_web` - `v0.1.0+6`](#firebase_performance_web---v0106)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `cloud_firestore_web` - `v2.6.9`
 - `cloud_firestore` - `v3.1.9`
 - `cloud_firestore_odm` - `v1.0.0-dev.9`
 - `cloud_functions_web` - `v4.2.8`
 - `cloud_functions` - `v3.2.8`
 - `firebase_analytics_web` - `v0.4.0+7`
 - `firebase_app_check_web` - `v0.0.5+6`
 - `firebase_app_check` - `v0.0.6+6`
 - `firebase_app_installations_web` - `v0.1.0+7`
 - `firebase_app_installations` - `v0.1.0+7`
 - `firebase_auth_web` - `v3.3.8`
 - `firebase_auth` - `v3.3.8`
 - `firebase_in_app_messaging` - `v0.6.0+8`
 - `firebase_crashlytics` - `v2.5.2`
 - `firebase_remote_config_web` - `v1.0.6`
 - `firebase_database_web` - `v0.2.0+6`
 - `firebase_database` - `v9.0.7`
 - `firebase_dynamic_links` - `v4.0.7`
 - `firebase_messaging_web` - `v2.2.8`
 - `firebase_ml_model_downloader` - `v0.1.0+7`
 - `firebase_storage_web` - `v3.2.9`
 - `firebase_storage` - `v10.2.8`
 - `firebase_performance_web` - `v0.1.0+6`

---

#### `cloud_firestore_odm_generator` - `v1.0.0-dev.9`

 - **FIX**: Use descending in orderBy* (#8159). ([0b7b8811](https://github.com/FirebaseExtended/flutterfire/commit/0b7b88117ac65a0ab164ffcaa0ca7fa69633fcb2))

#### `cloud_firestore_platform_interface` - `v5.5.0`

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/FirebaseExtended/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

#### `cloud_functions_platform_interface` - `v5.1.0`

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/FirebaseExtended/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

#### `firebase_analytics` - `v9.1.1`

 - **DOCS**: code comment typo - `logAdImpression` mentions wrong event (#8180). ([960a75a7](https://github.com/FirebaseExtended/flutterfire/commit/960a75a77dc8c575e7f8f9c4350ad564a3814eb8))

#### `firebase_analytics_platform_interface` - `v3.1.0`

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/FirebaseExtended/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

#### `firebase_app_check_platform_interface` - `v0.0.4`

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/FirebaseExtended/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

#### `firebase_app_installations_platform_interface` - `v0.1.1`

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/FirebaseExtended/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

#### `firebase_auth_platform_interface` - `v6.2.0`

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/FirebaseExtended/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

#### `firebase_core` - `v1.13.0`

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/FirebaseExtended/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

#### `firebase_core_web` - `v1.6.0`

 - **FEAT**: Bump Firebase Web SDK version to 8.10.1 (CVE-2022-0235) for security patch purposes. (#8162). ([7624f777](https://github.com/FirebaseExtended/flutterfire/commit/7624f7779f4a49f2353f3f593b31be9139197028))

#### `firebase_crashlytics_platform_interface` - `v3.2.0`

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/FirebaseExtended/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

#### `firebase_database_platform_interface` - `v0.2.1`

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/FirebaseExtended/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

#### `firebase_dynamic_links_platform_interface` - `v0.2.1`

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/FirebaseExtended/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

#### `firebase_in_app_messaging_platform_interface` - `v0.2.1`

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/FirebaseExtended/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

#### `firebase_messaging` - `v11.2.7`

 - **FIX**: Stream new token via onTokenRefresh when getToken invoked for iOS. (#8166). ([28b396b8](https://github.com/FirebaseExtended/flutterfire/commit/28b396b84e019a5247e70d0abeb1ba24bdff4bcb))

#### `firebase_messaging_platform_interface` - `v3.2.0`

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/FirebaseExtended/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

#### `firebase_ml_model_downloader_platform_interface` - `v0.1.1`

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/FirebaseExtended/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

#### `firebase_performance` - `v0.8.0+6`

 - **FIX**: Fix firebase_performance not recording response payload size on Android. (#8154). ([46d8bc0f](https://github.com/FirebaseExtended/flutterfire/commit/46d8bc0f205f24b1e160333ddb76200543f48c89))

#### `firebase_performance_platform_interface` - `v0.1.1`

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/FirebaseExtended/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

#### `firebase_remote_config` - `v2.0.1`

 - **FIX**: add missing `default_package` entry for web in `pubspec.yaml` (#8139). ([5e6b570f](https://github.com/FirebaseExtended/flutterfire/commit/5e6b570f8445b0bd2eac8b112a2a6b35ff69b7b6))

#### `firebase_remote_config_platform_interface` - `v1.1.0`

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/FirebaseExtended/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

#### `firebase_storage_platform_interface` - `v4.1.0`

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/FirebaseExtended/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

#### `flutterfire_ui` - `v0.3.5`

 - **FIX**: Upgrade `desktop_webview_auth` - v`0.0.5` (#8164). ([123fa6b1](https://github.com/FirebaseExtended/flutterfire/commit/123fa6b132183a4d6886c8be0595104752724532))
 - **FIX**: Upgrade `desktop_webview_auth` package causing a problem on macOS. (#8151). ([da4a1c5e](https://github.com/FirebaseExtended/flutterfire/commit/da4a1c5e074cb5af71983a3ae49c4838402b726f))
 - **FEAT**: Add support for configuring authentication providers globally (additionally fixes #7801) (#8120). ([ebde7d27](https://github.com/FirebaseExtended/flutterfire/commit/ebde7d27938d7a36a67973df4b33c21bbd7dea1a))
 - **FEAT**: Add Hindi localization language support (#7778). ([b584ce0f](https://github.com/FirebaseExtended/flutterfire/commit/b584ce0f254dcb195f9a31f279fb3871d01182c1))
 - **FEAT**: Add Turkish language localization support. (#7790). ([c47f6075](https://github.com/FirebaseExtended/flutterfire/commit/c47f60757ccbfcee1eaa5d7ed6ee01258f3b9d4f))
 - **FEAT**: Add Bahasa Indonesia localization language support (#7709). ([be0eb27f](https://github.com/FirebaseExtended/flutterfire/commit/be0eb27f4f4d85a4e4a2468768c166a701325a8c))
 - **FEAT**: Enhance the oauth provider button widget by showing error text underneath. (#8032). ([2b47f5a1](https://github.com/FirebaseExtended/flutterfire/commit/2b47f5a12747e3437dfc42d331684e798372beaf))


## 2022-02-10

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`cloud_firestore_odm` - `v1.0.0-dev.8`](#cloud_firestore_odm---v100-dev8)
 - [`cloud_firestore_platform_interface` - `v5.4.13`](#cloud_firestore_platform_interface---v5413)
 - [`firebase_auth` - `v3.3.7`](#firebase_auth---v337)
 - [`firebase_dynamic_links` - `v4.0.6`](#firebase_dynamic_links---v406)
 - [`flutterfire_ui` - `v0.3.4`](#flutterfire_ui---v034)
 - [`cloud_firestore_odm_generator` - `v1.0.0-dev.8`](#cloud_firestore_odm_generator---v100-dev8)
 - [`cloud_firestore` - `v3.1.8`](#cloud_firestore---v318)
 - [`cloud_firestore_web` - `v2.6.8`](#cloud_firestore_web---v268)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `cloud_firestore_odm_generator` - `v1.0.0-dev.8`
 - `cloud_firestore` - `v3.1.8`
 - `cloud_firestore_web` - `v2.6.8`

---

#### `cloud_firestore_odm` - `v1.0.0-dev.8`

 - **DOCS**: Update code snippets by removing incorrect forward slash for `@Collection` annotations. (#8044). ([292f20c6](https://github.com/FirebaseExtended/flutterfire/commit/292f20c61c0a479e5effcbf45a07f7fb782ba23e))

#### `cloud_firestore_platform_interface` - `v5.4.13`

 - **FIX**: Export enum `LoadBundleTaskState` from Platform Interface package. (#8027). ([7fa461e4](https://github.com/FirebaseExtended/flutterfire/commit/7fa461e4476db3ac255877db93b6ccf493d0e1cf))

#### `firebase_auth` - `v3.3.7`

 - **DOCS**: Update documentation for `currentUser` property to make expectations clearer. (#7843). ([59bb47c2](https://github.com/FirebaseExtended/flutterfire/commit/59bb47c2490fbd641a1fcc26f2f888e8f4f02671))

#### `firebase_dynamic_links` - `v4.0.6`

 - **FIX**: Ensure Dynamic link is retrieved from the Intent just once for `getInitialLink()` on Android as per the documentation. (#7743). ([67cc6647](https://github.com/FirebaseExtended/flutterfire/commit/67cc66471046822463f326c05e732313dbaa9560))

#### `flutterfire_ui` - `v0.3.4`

 - **FEAT**: Add Italian localization language support. (#7823). ([c3a1a839](https://github.com/FirebaseExtended/flutterfire/commit/c3a1a839a3963a75cc17e931a3eee6e091df40ac))


## 2022-02-08

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`firebase_storage_platform_interface` - `v4.0.14`](#firebase_storage_platform_interface---v4014)
 - [`firebase_crashlytics` - `v2.5.1`](#firebase_crashlytics---v251)
 - [`cloud_functions` - `v3.2.7`](#cloud_functions---v327)
 - [`flutterfire_ui` - `v0.3.3`](#flutterfire_ui---v033)
 - [`firebase_storage` - `v10.2.7`](#firebase_storage---v1027)
 - [`firebase_storage_web` - `v3.2.8`](#firebase_storage_web---v328)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `firebase_storage` - `v10.2.7`
 - `firebase_storage_web` - `v3.2.8`

---

#### `firebase_storage_platform_interface` - `v4.0.14`

 - **DOCS**: Update storage metadata code documentation and add relevant documentation links.

#### `firebase_crashlytics` - `v2.5.1`

 - **FIX**: Fixed macOS project not compiling by symlinking missing header file: `Crashlytics_Platform.h`

#### `cloud_functions` - `v3.2.7`

 - **REFACTOR**: remove deprecated Android API usages (#7986).

#### `flutterfire_ui` - `v0.3.3`

 - **FIX**: prompt user to select google account on web (#8007).
 - **FIX**: bump flutter_facebook_auth version (#8031).
 - **FIX**: make breakpoints of all screens configurable (#7996).
 - **FEAT**: add Dutch localization support (#7782).
 - **FEAT**: add autofillhints (#7668).
 - **DOCS**: Fixes "infinite" typo (#8039).

#### `firebase_storage` - `v10.2.7`


#### `firebase_storage_web` - `v3.2.8`



## 2022-01-27

### Changes

---

Packages with breaking changes:

- [`firebase_remote_config` - `v2.0.0`](#firebase_remote_config---v200)

Packages with other changes:

- [`cloud_firestore` - `v3.1.7`](#cloud_firestore---v317)
- [`cloud_firestore_odm_generator` - `v1.0.0-dev.7`](#cloud_firestore_odm_generator---v100-dev7)
- [`firebase_analytics` - `v9.1.0`](#firebase_analytics---v910)
- [`firebase_app_check` - `v0.0.6+5`](#firebase_app_check---v0065)
- [`firebase_app_installations` - `v0.1.0+6`](#firebase_app_installations---v0106)
- [`firebase_auth_web` - `v3.3.7`](#firebase_auth_web---v337)
- [`firebase_core` - `v1.12.0`](#firebase_core---v1120)
- [`firebase_core_platform_interface` - `v4.2.4`](#firebase_core_platform_interface---v424)
- [`firebase_crashlytics` - `v2.5.0`](#firebase_crashlytics---v250)
- [`firebase_database` - `v9.0.6`](#firebase_database---v906)
- [`firebase_database_platform_interface` - `v0.2.0+5`](#firebase_database_platform_interface---v0205)
- [`firebase_in_app_messaging` - `v0.6.0+7`](#firebase_in_app_messaging---v0607)
- [`firebase_messaging` - `v11.2.6`](#firebase_messaging---v1126)
- [`firebase_messaging_web` - `v2.2.7`](#firebase_messaging_web---v227)
- [`firebase_ml_model_downloader` - `v0.1.0+6`](#firebase_ml_model_downloader---v0106)
- [`flutterfire_ui` - `v0.3.2`](#flutterfire_ui---v032)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

- `cloud_firestore_odm` - `v1.0.0-dev.7`
- `firebase_auth` - `v3.3.6`
- `firebase_in_app_messaging_platform_interface` - `v0.2.0+7`
- `firebase_crashlytics_platform_interface` - `v3.1.13`
- `firebase_database_web` - `v0.2.0+5`
- `firebase_auth_platform_interface` - `v6.1.11`
- `firebase_remote_config_web` - `v1.0.5`
- `firebase_remote_config_platform_interface` - `v1.0.5`
- `firebase_dynamic_links` - `v4.0.5`
- `firebase_dynamic_links_platform_interface` - `v0.2.0+5`
- `cloud_firestore_web` - `v2.6.7`
- `cloud_firestore_platform_interface` - `v5.4.12`
- `firebase_messaging_platform_interface` - `v3.1.6`
- `firebase_analytics_platform_interface` - `v3.0.5`
- `firebase_app_installations_web` - `v0.1.0+6`
- `firebase_app_installations_platform_interface` - `v0.1.0+6`
- `firebase_analytics_web` - `v0.4.0+6`
- `firebase_ml_model_downloader_platform_interface` - `v0.1.0+6`
- `firebase_app_check_platform_interface` - `v0.0.3+5`
- `firebase_app_check_web` - `v0.0.5+5`
- `cloud_functions_platform_interface` - `v5.0.21`
- `firebase_storage_web` - `v3.2.7`
- `cloud_functions_web` - `v4.2.7`
- `cloud_functions` - `v3.2.6`
- `firebase_storage_platform_interface` - `v4.0.13`
- `firebase_storage` - `v10.2.6`
- `firebase_performance_web` - `v0.1.0+5`
- `firebase_performance_platform_interface` - `v0.1.0+5`
- `firebase_performance` - `v0.8.0+5`
- `firebase_core_web` - `v1.5.4`

---

#### `firebase_remote_config` - `v2.0.0`

 - **BREAKING** **REFACTOR**: deprecated `RemoteConfig` in favour of `FirebaseRemoteConfig` to align Firebase services naming with other plugins.

#### `cloud_firestore` - `v3.1.7`

 - **FIX**: Fix Android Firestore transaction crash when running in background caused by `null` `Activity`. (#7627).

#### `cloud_firestore_odm_generator` - `v1.0.0-dev.7`

 - **FEAT**: Added error handling for when the Firestore reference and the Model class are defined in two separate files. (#7885).

#### `firebase_analytics` - `v9.1.0`

 - **FEAT**: Improve `FirebaseAnalyticsObserver` so that it also fires events when the modal route changes. (#7711).

#### `firebase_app_check` - `v0.0.6+5`

 - **FIX**: workaround iOS build issue when targetting platforms < iOS 11.

#### `firebase_app_installations` - `v0.1.0+6`

 - **FIX**: setup missing Firebase internal SDK headers (#7513).

#### `firebase_auth_web` - `v3.3.7`

 - **FIX**: Add support for`dynamicLinkDomain` property to `ActionCodeSetting` for web. (#7683).

#### `firebase_core` - `v1.12.0`

 - **FEAT**: bump Firebase iOS SDK to `8.11.0` & Android SDK to `29.0.4` (#7942).

#### `firebase_core_platform_interface` - `v4.2.4`

 - **FIX**: allow secondary Firebase App initialization without duplicate app error on hot restart (#7953).
 - **FIX**: Fix `FirebaseException` error code bug by making default value: "unknown". (#6897).

#### `firebase_crashlytics` - `v2.5.0`

 - **FEAT**: Set the dSYM file format through the Crashlytic's podspec to allow symbolicating crash reports. (#7872).

#### `firebase_database` - `v9.0.6`

 - **FIX**: Fix `MissingPluginException` caused by malformed EventChannel name. (#7859).

#### `firebase_database_platform_interface` - `v0.2.0+5`

 - **FIX**: Fixed transaction bug by removing duplicate arguments when they are already set as defaults. (#7839).

#### `firebase_in_app_messaging` - `v0.6.0+7`

 - **FIX**: issue where Boolean value was always `true` for `setMessagesSuppressed ()` & `setAutomaticDataCollectionEnabled()` on iOS. (#7954).
 - **FIX**: setup missing Firebase internal SDK headers (#7513).

#### `firebase_messaging` - `v11.2.6`

 - **FIX**: Set APNS token if user initializes Firebase app from Flutter. (#7610).

#### `firebase_messaging_web` - `v2.2.7`

 - **FIX**: Make Web `deleteToken()` API a Future so it resolves only when completed. (#7687).

#### `firebase_ml_model_downloader` - `v0.1.0+6`

 - **FIX**: fixed an issue where macOS builds failed due to bug with missing pod subspec in Firebase SDK (added a workaround until issue fixed upstream).

#### `flutterfire_ui` - `v0.3.2`

 - **FEAT**: add Portuguese localization support (#7830).


## 2022-01-07

### Changes

---

Packages with breaking changes:

- There are no breaking changes in this release.

Packages with other changes:

- [`cloud_functions` - `v3.2.5`](#cloud_functions---v325)
- [`firebase_analytics` - `v9.0.5`](#firebase_analytics---v905)
- [`firebase_app_check` - `v0.0.6+4`](#firebase_app_check---v0064)
- [`firebase_app_installations` - `v0.1.0+5`](#firebase_app_installations---v0105)
- [`firebase_auth` - `v3.3.5`](#firebase_auth---v335)
- [`firebase_core` - `v1.11.0`](#firebase_core---v1110)
- [`firebase_crashlytics` - `v2.4.5`](#firebase_crashlytics---v245)
- [`firebase_database` - `v9.0.5`](#firebase_database---v905)
- [`firebase_dynamic_links_platform_interface` - `v0.2.0+4`](#firebase_dynamic_links_platform_interface---v0204)
- [`firebase_in_app_messaging` - `v0.6.0+6`](#firebase_in_app_messaging---v0606)
- [`firebase_messaging` - `v11.2.5`](#firebase_messaging---v1125)
- [`firebase_performance` - `v0.8.0+4`](#firebase_performance---v0804)
- [`firebase_remote_config` - `v1.0.4`](#firebase_remote_config---v104)
- [`firebase_storage` - `v10.2.5`](#firebase_storage---v1025)
- [`flutterfire_ui` - `v0.3.1`](#flutterfire_ui---v031)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

- `firebase_in_app_messaging_platform_interface` - `v0.2.0+6`
- `firebase_crashlytics_platform_interface` - `v3.1.12`
- `firebase_auth_web` - `v3.3.6`
- `firebase_auth_platform_interface` - `v6.1.10`
- `firebase_remote_config_platform_interface` - `v1.0.4`
- `firebase_database_platform_interface` - `v0.2.0+4`
- `firebase_remote_config_web` - `v1.0.4`
- `firebase_dynamic_links` - `v4.0.4`
- `firebase_database_web` - `v0.2.0+4`
- `cloud_firestore_web` - `v2.6.6`
- `cloud_firestore_platform_interface` - `v5.4.11`
- `firebase_app_installations_web` - `v0.1.0+5`
- `cloud_firestore` - `v3.1.6`
- `firebase_messaging_platform_interface` - `v3.1.5`
- `firebase_app_installations_platform_interface` - `v0.1.0+5`
- `firebase_messaging_web` - `v2.2.6`
- `firebase_analytics_platform_interface` - `v3.0.4`
- `firebase_analytics_web` - `v0.4.0+5`
- `firebase_ml_model_downloader_platform_interface` - `v0.1.0+5`
- `firebase_ml_model_downloader` - `v0.1.0+5`
- `firebase_app_check_platform_interface` - `v0.0.3+4`
- `firebase_app_check_web` - `v0.0.5+4`
- `cloud_functions_web` - `v4.2.6`
- `firebase_storage_web` - `v3.2.6`
- `cloud_functions_platform_interface` - `v5.0.20`
- `firebase_storage_platform_interface` - `v4.0.12`
- `firebase_performance_web` - `v0.1.0+4`
- `firebase_performance_platform_interface` - `v0.1.0+4`
- `cloud_firestore_odm` - `v1.0.0-dev.6`
- `cloud_firestore_odm_generator` - `v1.0.0-dev.6`

---

#### `cloud_functions` - `v3.2.5`

 - **FIX**: bump Android `compileSdkVersion` to 31 (#7726).

#### `firebase_analytics` - `v9.0.5`

 - **FIX**: bump Android `compileSdkVersion` to 31 (#7726).
 - **FIX**: user id and user properties can be null so `NSNull` should be converted to `nil` on iOS/macOS (#7810).
 - **FIX**: `setUserProperty` should now accept null as a valid value on Android (#7735).
 - **DOCS**: example app initialization and docs support status (#7745).

#### `firebase_app_check` - `v0.0.6+4`

 - **FIX**: bump Android `compileSdkVersion` to 31 (#7726).

#### `firebase_app_installations` - `v0.1.0+5`

 - **FIX**: bump Android `compileSdkVersion` to 31 (#7726).

#### `firebase_auth` - `v3.3.5`

 - **FIX**: bump Android `compileSdkVersion` to 31 (#7726).

#### `firebase_core` - `v1.11.0`

 - **FIX**: bump Android `compileSdkVersion` to 31 (#7726).
 - **FIX**: bump Firebase Android SDK version to `29.0.3` (from `29.0.0`).
 - **FIX**: workaround an SDK issue on Android where calling `initializeApp` when having `In App Messaging` installed causes a crash.
 - **FEAT**: bump Firebase iOS SDK version to `8.10.0`. (#7775).

#### `firebase_crashlytics` - `v2.4.5`

 - **FIX**: bump Android `compileSdkVersion` to 31 (#7726).

#### `firebase_database` - `v9.0.5`

 - **FIX**: bump Android `compileSdkVersion` to 31 (#7726).

#### `firebase_dynamic_links_platform_interface` - `v0.2.0+4`

 - **FIX**: `PendingDynamicLinkData.asString()` prints out instance type with mapped values. (#7727).

#### `firebase_in_app_messaging` - `v0.6.0+6`

 - **FIX**: bump Android `compileSdkVersion` to 31 (#7726).
 - **FIX**: lazily get the default `FirebaseInAppMessaging` instance on Android to allow for Firebase initialization via Dart only.
 - **FIX**: issue where Dart only initialization did not function correctly on iOS.

#### `firebase_messaging` - `v11.2.5`

 - **FIX**: bump Android `compileSdkVersion` to 31 (#7726).

#### `firebase_performance` - `v0.8.0+4`

 - **FIX**: bump Android `compileSdkVersion` to 31 (#7726).

#### `firebase_remote_config` - `v1.0.4`

 - **FIX**: bump Android `compileSdkVersion` to 31 (#7726).

#### `firebase_storage` - `v10.2.5`

 - **FIX**: bump Android `compileSdkVersion` to 31 (#7726).

#### `flutterfire_ui` - `v0.3.1`

 - **FIX**: fix `ResponsivePage` overflow issue (#7792).
 - **FIX**: export `DifferentSignInMethodsFound` auth state and make sure to add it to the list of provided actions (#7789).
 - **FIX**: validate email with the library instead of the `RegExp` (#7772).
 - **FIX**: not working `onTap` in `OAuthProviderButtonWidget` (#7641).
 - **FIX**: pass auth down to `LoginView` (#7645).
 - **FEAT**: add `Spanish` localization support (#7716).
 - **FEAT**: add `French` localization support (#7797).
 - **FEAT**: add `Arabic` localization support (#7771).
 - **DOCS**: update repository and homepage url (#7781).
 - **DOCS**: add missing `providerConfigs` in example (#7724).


## 2021-12-16

### Changes

---

Packages with breaking changes:

- [`flutterfire_ui` - `v0.3.0`](#flutterfire_ui---v030)

Packages with other changes:

- [`cloud_firestore` - `v3.1.5`](#cloud_firestore---v315)
- [`cloud_firestore_odm_generator` - `v1.0.0-dev.5`](#cloud_firestore_odm_generator---v100-dev5)
- [`cloud_firestore_platform_interface` - `v5.4.10`](#cloud_firestore_platform_interface---v5410)
- [`cloud_firestore_web` - `v2.6.5`](#cloud_firestore_web---v265)
- [`cloud_functions` - `v3.2.4`](#cloud_functions---v324)
- [`cloud_functions_platform_interface` - `v5.0.19`](#cloud_functions_platform_interface---v5019)
- [`firebase_analytics` - `v9.0.4`](#firebase_analytics---v904)
- [`firebase_analytics_platform_interface` - `v3.0.3`](#firebase_analytics_platform_interface---v303)
- [`firebase_app_check` - `v0.0.6+3`](#firebase_app_check---v0063)
- [`firebase_app_check_platform_interface` - `v0.0.3+3`](#firebase_app_check_platform_interface---v0033)
- [`firebase_auth` - `v3.3.4`](#firebase_auth---v334)
- [`firebase_auth_platform_interface` - `v6.1.9`](#firebase_auth_platform_interface---v619)
- [`firebase_core` - `v1.10.6`](#firebase_core---v1106)
- [`firebase_core_platform_interface` - `v4.2.3`](#firebase_core_platform_interface---v423)
- [`firebase_crashlytics` - `v2.4.4`](#firebase_crashlytics---v244)
- [`firebase_crashlytics_platform_interface` - `v3.1.11`](#firebase_crashlytics_platform_interface---v3111)
- [`firebase_database` - `v9.0.4`](#firebase_database---v904)
- [`firebase_dynamic_links` - `v4.0.3`](#firebase_dynamic_links---v403)
- [`firebase_messaging` - `v11.2.4`](#firebase_messaging---v1124)
- [`firebase_ml_model_downloader` - `v0.1.0+4`](#firebase_ml_model_downloader---v0104)
- [`firebase_ml_model_downloader_platform_interface` - `v0.1.0+4`](#firebase_ml_model_downloader_platform_interface---v0104)
- [`firebase_performance_platform_interface` - `v0.1.0+3`](#firebase_performance_platform_interface---v0103)
- [`firebase_storage` - `v10.2.4`](#firebase_storage---v1024)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

- `cloud_firestore_odm` - `v1.0.0-dev.5`
- `cloud_functions_web` - `v4.2.5`
- `firebase_analytics_web` - `v0.4.0+4`
- `firebase_app_check_web` - `v0.0.5+3`
- `firebase_auth_web` - `v3.3.5`
- `firebase_in_app_messaging` - `v0.6.0+5`
- `firebase_in_app_messaging_platform_interface` - `v0.2.0+5`
- `firebase_remote_config` - `v1.0.3`
- `firebase_remote_config_web` - `v1.0.3`
- `firebase_remote_config_platform_interface` - `v1.0.3`
- `firebase_database_web` - `v0.2.0+3`
- `firebase_database_platform_interface` - `v0.2.0+3`
- `firebase_dynamic_links_platform_interface` - `v0.2.0+3`
- `firebase_app_installations_web` - `v0.1.0+4`
- `firebase_app_installations` - `v0.1.0+4`
- `firebase_app_installations_platform_interface` - `v0.1.0+4`
- `firebase_messaging_web` - `v2.2.5`
- `firebase_messaging_platform_interface` - `v3.1.4`
- `firebase_storage_web` - `v3.2.5`
- `firebase_storage_platform_interface` - `v4.0.11`
- `firebase_performance_web` - `v0.1.0+3`
- `firebase_performance` - `v0.8.0+3`
- `firebase_core_web` - `v1.5.3`

---

#### `flutterfire_ui` - `v0.3.0`

 - **FIX**: add missing export for `ProviderConfiguration` (#7585).
 - **FIX**: some OAuth providers now work on macOS & web (#7576).
 - **FIX**: fix various typos in i10n text (#7624).
 - **BREAKING** **FEAT**: update all dependencies to use latest releases (#7549).
   - Note this has no breaking public API changes, however if you additionally also depend on some of the same dependencies in your app, e.g. `flutter_svg` then you may need to update your versions of these packages as well in your app `pubspec.yaml` to 
   avoid version resolution issues when running `pub get`.

#### `cloud_firestore` - `v3.1.5`

 - **REFACTOR**: fix all `unnecessary_import` analyzer issues introduced with Flutter 2.8.

 #### `cloud_firestore_odm_generator` - `v1.0.0-dev.5`

 - **FIX**: an issue where invalid code was generated when a model has no queryable fields (#7604).

#### `cloud_firestore_platform_interface` - `v5.4.10`

 - **REFACTOR**: fix all `unnecessary_import` analyzer issues introduced with Flutter 2.8.

#### `cloud_firestore_web` - `v2.6.5`

 - **REFACTOR**: fix all `unnecessary_import` analyzer issues introduced with Flutter 2.8.

#### `cloud_functions` - `v3.2.4`

 - **REFACTOR**: fix all `unnecessary_import` analyzer issues introduced with Flutter 2.8.

#### `cloud_functions_platform_interface` - `v5.0.19`

 - **REFACTOR**: fix all `unnecessary_import` analyzer issues introduced with Flutter 2.8.

#### `firebase_analytics` - `v9.0.4`

 - **REFACTOR**: fix all `unnecessary_import` analyzer issues introduced with Flutter 2.8.

#### `firebase_analytics_platform_interface` - `v3.0.3`

 - **REFACTOR**: fix all `unnecessary_import` analyzer issues introduced with Flutter 2.8.

#### `firebase_app_check` - `v0.0.6+3`

 - **REFACTOR**: fix all `unnecessary_import` analyzer issues introduced with Flutter 2.8.

#### `firebase_app_check_platform_interface` - `v0.0.3+3`

 - **REFACTOR**: fix all `unnecessary_import` analyzer issues introduced with Flutter 2.8.

#### `firebase_auth` - `v3.3.4`

 - **REFACTOR**: fix all `unnecessary_import` analyzer issues introduced with Flutter 2.8.

#### `firebase_auth_platform_interface` - `v6.1.9`

 - **REFACTOR**: fix all `unnecessary_import` analyzer issues introduced with Flutter 2.8.

#### `firebase_core` - `v1.10.6`

 - **REFACTOR**: fix all `unnecessary_import` analyzer issues introduced with Flutter 2.8.

#### `firebase_core_platform_interface` - `v4.2.3`

 - **REFACTOR**: fix all `unnecessary_import` analyzer issues introduced with Flutter 2.8.

#### `firebase_crashlytics` - `v2.4.4`

 - **REFACTOR**: fix all `unnecessary_import` analyzer issues introduced with Flutter 2.8.
 - **FIX**: set build id as not required, to allow Dart default app initialization (#7594).
 - **FIX**: Return app constants for default app only on `Android`. (#7592).

#### `firebase_crashlytics_platform_interface` - `v3.1.11`

 - **REFACTOR**: fix all `unnecessary_import` analyzer issues introduced with Flutter 2.8.

#### `firebase_database` - `v9.0.4`

 - **REFACTOR**: fix all `unnecessary_import` analyzer issues introduced with Flutter 2.8.
 - **FIX**: remove trailing `/` from `databaseUrl` if present. (#7601).

#### `firebase_dynamic_links` - `v4.0.3`

 - **REFACTOR**: fix all `unnecessary_import` analyzer issues introduced with Flutter 2.8.

#### `firebase_messaging` - `v11.2.4`

 - **FIX**: Return app constants for default app only on `Android`. (#7592).

#### `firebase_ml_model_downloader` - `v0.1.0+4`

 - **REFACTOR**: fix all `unnecessary_import` analyzer issues introduced with Flutter 2.8.

#### `firebase_ml_model_downloader_platform_interface` - `v0.1.0+4`

 - **REFACTOR**: fix all `unnecessary_import` analyzer issues introduced with Flutter 2.8.

#### `firebase_performance_platform_interface` - `v0.1.0+3`

 - **REFACTOR**: fix all `unnecessary_import` analyzer issues introduced with Flutter 2.8.
 - **FIX**: `HttpMetric` send only non-null values on `stop()` (#7593).

#### `firebase_storage` - `v10.2.4`

 - **REFACTOR**: fix all `unnecessary_import` analyzer issues introduced with Flutter 2.8.


## 2021-12-10

### Changes

---

Packages with breaking changes:

- There are no breaking changes in this release.

Packages with other changes:

- [`firebase_analytics` - `v9.0.3`](#firebase_analytics---v903)
- [`firebase_analytics_web` - `v0.4.0+3`](#firebase_analytics_web---v0403)
- [`firebase_database` - `v9.0.3`](#firebase_database---v903)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

- `flutterfire_ui` - `v0.2.0+2`

---

#### `firebase_analytics` - `v9.0.3`

 - **FIX**: ensure `setDefaultEventParameters()` API throws stating not supported on web. (#7522).
 - **FIX**: reinstate Analytics screen navigation observer. (#7529).
 - **FIX**: userId can be null (#7545).

#### `firebase_analytics_web` - `v0.4.0+3`

 - **FIX**: ensure `setDefaultEventParameters()` API throws stating not supported on web. (#7522).

#### `firebase_database` - `v9.0.3`

 - **FIX**: downgrade the Android min SDK to 19 (#7533).


## 2021-12-08

### Changes

---

Packages with breaking changes:

- There are no breaking changes in this release.

Packages with other changes:

- [`firebase_core_platform_interface` - `v4.2.2`](#firebase_core_platform_interface---v422)
- [`firebase_core_web` - `v1.5.2`](#firebase_core_web---v152)
- [`firebase_database` - `v9.0.2`](#firebase_database---v902)
- [`firebase_database_platform_interface` - `v0.2.0+2`](#firebase_database_platform_interface---v0202)
- [`firebase_database_web` - `v0.2.0+2`](#firebase_database_web---v0202)
- [`firebase_messaging_web` - `v2.2.4`](#firebase_messaging_web---v224)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

- `firebase_in_app_messaging` - `v0.6.0+4`
- `firebase_crashlytics` - `v2.4.3`
- `firebase_auth` - `v3.3.3`
- `firebase_remote_config` - `v1.0.2`
- `firebase_dynamic_links` - `v4.0.2`
- `firebase_app_installations` - `v0.1.0+3`
- `cloud_firestore` - `v3.1.4`
- `firebase_messaging` - `v11.2.3`
- `firebase_core` - `v1.10.5`
- `firebase_analytics` - `v9.0.2`
- `firebase_ml_model_downloader` - `v0.1.0+3`
- `firebase_app_check` - `v0.0.6+2`
- `cloud_functions` - `v3.2.3`
- `firebase_storage` - `v10.2.3`
- `firebase_performance` - `v0.8.0+2`
- `flutterfire_ui` - `v0.2.0+1`
- `cloud_firestore_odm` - `v1.0.0-dev.4`
- `firebase_auth_web` - `v3.3.4`
- `firebase_remote_config_web` - `v1.0.2`
- `cloud_firestore_web` - `v2.6.4`
- `firebase_app_installations_web` - `v0.1.0+3`
- `firebase_analytics_web` - `v0.4.0+2`
- `firebase_app_check_web` - `v0.0.5+2`
- `cloud_functions_web` - `v4.2.4`
- `firebase_storage_web` - `v3.2.4`
- `firebase_performance_web` - `v0.1.0+2`
- `firebase_in_app_messaging_platform_interface` - `v0.2.0+4`
- `firebase_crashlytics_platform_interface` - `v3.1.10`
- `firebase_auth_platform_interface` - `v6.1.8`
- `firebase_remote_config_platform_interface` - `v1.0.2`
- `firebase_dynamic_links_platform_interface` - `v0.2.0+2`
- `firebase_app_installations_platform_interface` - `v0.1.0+3`
- `firebase_messaging_platform_interface` - `v3.1.3`
- `cloud_firestore_platform_interface` - `v5.4.9`
- `firebase_analytics_platform_interface` - `v3.0.2`
- `firebase_ml_model_downloader_platform_interface` - `v0.1.0+3`
- `firebase_app_check_platform_interface` - `v0.0.3+2`
- `cloud_functions_platform_interface` - `v5.0.18`
- `firebase_storage_platform_interface` - `v4.0.10`
- `firebase_performance_platform_interface` - `v0.1.0+2`
- `cloud_firestore_odm_generator` - `v1.0.0-dev.4`

---

#### `firebase_core_platform_interface` - `v4.2.2`

 - **FIX**: correctly detect `not-initialized` errors and provide a better error message.

#### `firebase_core_web` - `v1.5.2`

 - **FIX**: correctly detect `not-initialized` errors and provide a better error message.

#### `firebase_database` - `v9.0.2`

 - **FIX**: web reference `path` should now correctly return a path string.
 - **FIX**: database path should default to `/` if no path specified rather than an empty string (fixes #7515).

#### `firebase_database_platform_interface` - `v0.2.0+2`

 - **FIX**: database path should default to `/` if no path specified rather than an empty string (fixes #7515).

#### `firebase_database_web` - `v0.2.0+2`

 - **FIX**: web reference `path` should now correctly return a path string.

#### `firebase_messaging_web` - `v2.2.4`

 - **FIX**: messaging `isSupported()` check on web should be used lazily in `_delegate` (fixes #7511).


## 2021-12-08

### Changes

---

Packages with breaking changes:

- [`flutterfire_ui` - `v0.2.0`](#flutterfire_ui---v020)

Packages with other changes:

- [`cloud_firestore` - `v3.1.3`](#cloud_firestore---v313)
- [`firebase_analytics` - `v9.0.1`](#firebase_analytics---v901)
- [`firebase_analytics_web` - `v0.4.0+1`](#firebase_analytics_web---v0401)
- [`firebase_auth` - `v3.3.2`](#firebase_auth---v332)
- [`firebase_auth_platform_interface` - `v6.1.7`](#firebase_auth_platform_interface---v617)
- [`firebase_core_platform_interface` - `v4.2.1`](#firebase_core_platform_interface---v421)
- [`firebase_database` - `v9.0.1`](#firebase_database---v901)
- [`firebase_database_platform_interface` - `v0.2.0+1`](#firebase_database_platform_interface---v0201)
- [`firebase_messaging` - `v11.2.2`](#firebase_messaging---v1122)
- [`firebase_remote_config` - `v1.0.1`](#firebase_remote_config---v101)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

- `cloud_firestore_odm` - `v1.0.0-dev.3`
- `cloud_firestore_odm_generator` - `v1.0.0-dev.3`
- `firebase_auth_web` - `v3.3.3`
- `firebase_in_app_messaging` - `v0.6.0+3`
- `firebase_crashlytics` - `v2.4.2`
- `firebase_dynamic_links` - `v4.0.1`
- `firebase_app_installations` - `v0.1.0+2`
- `firebase_core_web` - `v1.5.1`
- `firebase_core` - `v1.10.4`
- `firebase_ml_model_downloader` - `v0.1.0+2`
- `firebase_app_check` - `v0.0.6+1`
- `cloud_functions` - `v3.2.2`
- `firebase_storage` - `v10.2.2`
- `firebase_performance` - `v0.8.0+1`
- `firebase_remote_config_web` - `v1.0.1`
- `firebase_database_web` - `v0.2.0+1`
- `cloud_firestore_web` - `v2.6.3`
- `firebase_app_installations_web` - `v0.1.0+2`
- `firebase_messaging_web` - `v2.2.3`
- `firebase_app_check_web` - `v0.0.5+1`
- `cloud_functions_web` - `v4.2.3`
- `firebase_storage_web` - `v3.2.3`
- `firebase_performance_web` - `v0.1.0+1`
- `firebase_in_app_messaging_platform_interface` - `v0.2.0+3`
- `firebase_crashlytics_platform_interface` - `v3.1.9`
- `firebase_remote_config_platform_interface` - `v1.0.1`
- `firebase_dynamic_links_platform_interface` - `v0.2.0+1`
- `cloud_firestore_platform_interface` - `v5.4.8`
- `firebase_app_installations_platform_interface` - `v0.1.0+2`
- `firebase_messaging_platform_interface` - `v3.1.2`
- `firebase_analytics_platform_interface` - `v3.0.1`
- `firebase_ml_model_downloader_platform_interface` - `v0.1.0+2`
- `firebase_app_check_platform_interface` - `v0.0.3+1`
- `firebase_storage_platform_interface` - `v4.0.9`
- `cloud_functions_platform_interface` - `v5.0.17`
- `firebase_performance_platform_interface` - `v0.1.0+1`

---

#### `flutterfire_ui` - `v0.2.0`

 - **FIX**: fix issue with web and phone authentication (#7506).
 - **DOCS**: add readme documentation (#7508).
 - **DOCS**: Fix typos and remove unused imports (#7504).
 - **BREAKING** **FIX**: rename `QueryBuilderSnapshot` ->  `FirebaseQueryBuilderSnapshot` plus internal improvements and additional documentation (#7503).

#### `cloud_firestore` - `v3.1.3`

 - **DOCS**: update firestore dartpad example.

#### `firebase_analytics` - `v9.0.1`

 - **FIX**: use `jsify()` with event parameters for `logEvent()` so they are sent (#7509).

#### `firebase_analytics_web` - `v0.4.0+1`

 - **FIX**: use `jsify()` with event parameters for `logEvent()` so they are sent (#7509).

#### `firebase_auth` - `v3.3.2`

 - **DOCS**: Fix typos and remove unused imports (#7504).

#### `firebase_auth_platform_interface` - `v6.1.7`

 - **DOCS**: Fix typos and remove unused imports (#7504).

#### `firebase_core_platform_interface` - `v4.2.1`

 - **FIX**: loosen duplicate app detection checks to allow unset options not to cause a duplicate app exception (#7499).

#### `firebase_database` - `v9.0.1`

 - **FIX**: issue where setting a `databaseURL` can sometimes be ignored (fixes #7502) (#7510).
 - **FIX**: add missing `path` getter for Query (fixes #7495).
 - **DOCS**: fix changelog formatting.
 - **DOCS**: update documentation of `setPersistenceEnabled` to reflect updated return type (fixes #7496) (#7501).

#### `firebase_database_platform_interface` - `v0.2.0+1`

 - **FIX**: query modifier asserts not correctly triggering.

#### `firebase_messaging` - `v11.2.2`

 - **DOCS**: Fix typos and remove unused imports (#7504).

#### `firebase_remote_config` - `v1.0.1`

 - **DOCS**: Fix typos and remove unused imports (#7504).


## 2021-12-08

### Changes

---

Packages with breaking changes:

- There are no breaking changes in this release.

Packages with other changes:

- [`flutterfire_ui` - `v0.1.0+1`](#flutterfire_ui---v0101)

---

#### `flutterfire_ui` - `v0.1.0+1`

 - **FIX**: email link sign in and add additional documentation (#7493).


## 2021-12-07 (1)

### Changes

---

Packages with breaking changes:

- There are no breaking changes in this release.

Packages with other changes:

- There are no other changes in this release.

Packages graduated to a stable release (see pre-releases prior to the stable version for changelog entries):

- `firebase_analytics` - `v9.0.0`
- `firebase_analytics_platform_interface` - `v3.0.0`
- `firebase_analytics_web` - `v0.4.0`
- `firebase_database` - `v9.0.0`
- `firebase_database_platform_interface` - `v0.2.0`
- `firebase_database_web` - `v0.2.0`
- `firebase_dynamic_links` - `v4.0.0`
- `firebase_dynamic_links_platform_interface` - `v0.2.0`
- `firebase_performance` - `v0.8.0`
- `firebase_performance_platform_interface` - `v0.1.0`
- `firebase_performance_web` - `v0.1.0`
- `firebase_remote_config` - `v1.0.0`
- `firebase_remote_config_platform_interface` - `v1.0.0`
- `firebase_remote_config_web` - `v1.0.0`
- `flutterfire_ui` - `v0.1.0`

## 2021-12-07

### Changes

---

Packages with breaking changes:

- There are no breaking changes in this release.

Packages with other changes:

- [`firebase_app_check` - `v0.0.6`](#firebase_app_check---v006)
- [`firebase_app_check_platform_interface` - `v0.0.3`](#firebase_app_check_platform_interface---v003)
- [`firebase_app_check_web` - `v0.0.5`](#firebase_app_check_web---v005)
- [`firebase_core_web` - `v1.5.0`](#firebase_core_web---v150)
- [`firebase_database` - `v9.0.0-dev.1`](#firebase_database---v900-dev1)
- [`firebase_database_web` - `v0.2.0-dev.1`](#firebase_database_web---v020-dev1)
- [`firebase_ml_model_downloader` - `v0.1.0+1`](#firebase_ml_model_downloader---v0101)
- [`firebase_ml_model_downloader_platform_interface` - `v0.1.0+1`](#firebase_ml_model_downloader_platform_interface---v0101)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

- `firebase_auth_web` - `v3.3.2`
- `firebase_remote_config_web` - `v1.0.0-dev.5`
- `cloud_firestore_web` - `v2.6.2`
- `firebase_app_installations_web` - `v0.1.0+1`
- `firebase_messaging_web` - `v2.2.2`
- `firebase_core` - `v1.10.3`
- `firebase_analytics_web` - `v0.4.0-dev.6`
- `cloud_functions_web` - `v4.2.2`
- `firebase_storage_web` - `v3.2.2`
- `firebase_performance_web` - `v0.1.0-dev.1`
- `firebase_auth` - `v3.3.1`
- `firebase_remote_config` - `v1.0.0-dev.4`
- `cloud_firestore` - `v3.1.2`
- `firebase_app_installations` - `v0.1.0+1`
- `firebase_messaging` - `v11.2.1`
- `firebase_in_app_messaging` - `v0.6.0+2`
- `firebase_in_app_messaging_platform_interface` - `v0.2.0+2`
- `firebase_crashlytics` - `v2.4.1`
- `firebase_crashlytics_platform_interface` - `v3.1.8`
- `firebase_auth_platform_interface` - `v6.1.6`
- `firebase_remote_config_platform_interface` - `v1.0.0-dev.4`
- `firebase_database_platform_interface` - `v0.2.0-dev.1`
- `firebase_dynamic_links` - `v4.0.0-dev.2`
- `firebase_dynamic_links_platform_interface` - `v0.2.0-dev.2`
- `cloud_firestore_platform_interface` - `v5.4.7`
- `firebase_app_installations_platform_interface` - `v0.1.0+1`
- `firebase_messaging_platform_interface` - `v3.1.1`
- `firebase_analytics_platform_interface` - `v3.0.0-dev.5`
- `flutterfire_ui` - `v0.1.0-dev.5`
- `firebase_analytics` - `v9.0.0-dev.5`
- `cloud_functions` - `v3.2.1`
- `cloud_functions_platform_interface` - `v5.0.16`
- `firebase_storage_platform_interface` - `v4.0.8`
- `firebase_storage` - `v10.2.1`
- `firebase_performance_platform_interface` - `v0.1.0-dev.1`
- `firebase_performance` - `v0.8.0-dev.1`
- `cloud_firestore_odm` - `v1.0.0-dev.2`
- `cloud_firestore_odm_generator` - `v1.0.0-dev.2`

---

#### `firebase_app_check` - `v0.0.6`

 - **FEAT**: add token apis and documentation (#7419).

#### `firebase_app_check_platform_interface` - `v0.0.3`

 - **FEAT**: add token apis and documentation (#7419).

#### `firebase_app_check_web` - `v0.0.5`

 - **FEAT**: add token apis and documentation (#7419).

#### `firebase_core_web` - `v1.5.0`

 - **FEAT**: initial Firebase Installations release (#7377).

#### `firebase_database` - `v9.0.0-dev.1`

 - **FIX**: ignore emulator already set error on web (hot restart issue) (#7483).

#### `firebase_database_web` - `v0.2.0-dev.1`

 - **FIX**: ignore emulator already set error on web (hot restart issue) (#7483).

#### `firebase_ml_model_downloader` - `v0.1.0+1`

 - **FIX**: listDownloadedModels cast error (#7486).

#### `firebase_ml_model_downloader_platform_interface` - `v0.1.0+1`

 - **FIX**: listDownloadedModels cast error (#7486).


## 2021-12-04

### Changes

---

Packages with breaking changes:

- [`firebase_dynamic_links` - `v4.0.0-dev.0`](#firebase_dynamic_links---v400-dev0)

Packages with other changes:

- There are no other changes in this release.

---

#### `firebase_dynamic_links` - `v4.0.0-dev.0`

Firebase Dynamic Links has been reworked to bring it inline with the federated plugin setup along with adding new features,
documentation and updating unit and end-to-end tests.

- **`FirebaseDynamicLinks`**
  - **BREAKING**: `onLink()` method has been removed. Instead, use `onLink` getter, it returns a `Stream`; events & errors are now streamed to the user.
  - **BREAKING**: `DynamicLinkParameters` class has been removed. `buildLink()` (replaces `buildUrl()`) & `buildShortLink()` methods are now found on `FirebaseDynamicLinks.instance`.
  - **BREAKING**: `DynamicLinkParameters.shortenUrl()` has been removed.
  - **NEW**: `buildLink()` which replaces the previous `DynamicLinkParameters().buildUrl()`.
  - **NEW**: `buildShortLink()` which replaces the previous `DynamicLinkParameters().buildShortLink()`.
  - **NEW**: `DynamicLinkParameters` class is used to build parameters for `buildLink()` & `buildShortLink()`.
  - **NEW**: Multi-app support now available for Android only using `FirebaseDynamicLinks.instanceFor()`.

#### `firebase_dynamic_links_platform_interface` - `v0.2.0-dev.0`

 - Initial dev release of platform interface.


## 2021-12-03 (1)

### Changes

---

Packages with breaking changes:

- [`firebase_database` - `v9.0.0-dev.0`](#firebase_database---v900-dev0)
- [`firebase_database_platform_interface` - `v0.2.0-dev.0`](#firebase_database_platform_interface---v020-dev0)
- [`firebase_database_web` - `v0.2.0-dev.0`](#firebase_database_web---v020-dev0)

Packages with other changes:

- There are no other changes in this release.

---

#### `firebase_database` - `v9.0.0-dev.0`


Realtime Database has been fully reworked to bring the plugin inline with the federated plugin
setup, a more familiar API, better documentation and many more unit and end-to-end tests.

- General
- Fixed an issue where providing a `Map` with `int` keys would crash.

- `FirebaseDatabase`
- **DEPRECATED**: `FirebaseDatabase()` has now been deprecated in favor of `FirebaseDatabase.instanceFor()`.
- **DEPRECATED**: `reference()` has now been deprecated in favor of `ref()`.
- **NEW**: Added support for `ref()`, which allows you to provide an optional path to any database node rather than calling `child()`.
- **NEW**: Add emulator support via `useDatabaseEmulator()`.
- **NEW**: Add support for  `refFromURL()`.
- **BREAKING**: `setPersistenceEnabled()` is now synchronous.
- **BREAKING**: `setPersistenceCacheSizeBytes()` is now synchronous.
- **BREAKING**: `setLoggingEnabled()` is now synchronous.

- `DatabaseReference`
- **BREAKING**: `parent` is now a getter (inline with the JavaScript API).
- **BREAKING**: `root` is now a getter (inline with the JavaScript API).
- **BREAKING**: `set()` now accepts an `Object?` value (rather than `dynamic`) and no longer accepts a priority.
- **NEW**: Added support for `setWithPriority()`.
- **NEW**: Added support for locally applying transaction results via the `applyLocally` property on `runTransaction`.

- `Query`
- **NEW**: `once()` now accepts an optional `DatabaseEventType` (rather than just subscribing to the value).
- **BREAKING**: `limitToFirst()` now asserts the value is positive.
- **BREAKING**: `limitToLast()` now asserts the value is positive.

- `OnDisconnect`
  - **BREAKING**: `set()` now accepts an `Object?` value (rather than `dynamic`) and no longer accepts a priority.
  - **NEW**: Added support for `setWithPriority()`.

- `Event`
- **BREAKING**: The `Event` class returned from database queries has been renamed to `DatabaseEvent`.

- **NEW**: `DatabaseEvent` (old `Event`)
- The `DatabaseEventType` is now returned on the event.
- The `previousChildKey` is now returned on the event (previously called `previousSiblingKey`).

- **NEW**: `DatabaseEventType`
- A `DatabaseEventType` is now returned from a `DatabaseEvent`.

- `DataSnapshot`
- **NEW**: Added support for accessing the priority via the `.priority` getter.
- **NEW**: Added support for determining whether the snapshot has a child via `hasChild()`.
- **NEW**: Added support for accessing a snapshot child node via `child()`.
- **NEW**: Added support for iterating the child nodes of the snapshot via the `.children` getter.
  - **BREAKING** `snapshot.value` are no longer pre-sorted when using order queries, use `.children`
    if you need to iterate over your value keys in order.

- `TransactionResult`
- **BREAKING**: The result of a transaction no longer returns a `DatabaseError`, instead handle errors of a transaction via a `Future` completion error.

- **NEW**: `Transaction`
  - **NEW**: Added `Transaction.success(value)` return this from inside your  `TransactionHandler` to indicate a successful execution.
  - **NEW**: Added `Transaction.abort()` return this from inside your  `TransactionHandler` to indicate that the transaction should be aborted.

- `TransactionHandler`
  - **BREAKING** Transaction handlers must now always return an instance of `Transaction` either via `Transaction.success()` or `Transaction.abort()`.

- `DatabaseError`
- **BREAKING**: The `DatabaseError` class has been removed. Errors are now returned as a `FirebaseException` inline with the other plugins.


#### `firebase_database_platform_interface` - `v0.2.0-dev.0`

 - **BREAKING** **REFACTOR**: rework as part of #6979 (#7202).

#### `firebase_database_web` - `v0.2.0-dev.0`

 - **BREAKING** **REFACTOR**: rework as part of #6979 (#7202).


## 2021-12-03

### Changes

---

Packages with breaking changes:

- There are no breaking changes in this release.

Packages with other changes:

- [`firebase_core_web` - `v1.4.0`](#firebase_core_web---v140)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

- `firebase_auth_web` - `v3.3.1`
- `firebase_database_web` - `v0.1.2+1`
- `firebase_remote_config_web` - `v1.0.0-dev.4`
- `cloud_firestore_web` - `v2.6.1`
- `firebase_messaging_web` - `v2.2.1`
- `firebase_core` - `v1.10.2`
- `firebase_analytics_web` - `v0.4.0-dev.5`
- `firebase_app_check_web` - `v0.0.3+1`
- `cloud_functions_web` - `v4.2.1`
- `firebase_storage_web` - `v3.2.1`
- `firebase_performance_web` - `v0.0.3+1`

---

#### `firebase_core_web` - `v1.4.0`

 - **FEAT**: bump Firebase JS SDK to `8.10.0` (#7460).


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
