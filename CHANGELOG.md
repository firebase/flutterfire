# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## 2022-10-03

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`firebase_app_check` - `v0.0.9`](#firebase_app_check---v009)
 - [`firebase_auth` - `v3.11.1`](#firebase_auth---v3120)
 - [`flutterfire_ui` - `v0.4.3+12`](#flutterfire_ui---v04312)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flutterfire_ui` - `v0.4.3+12`

---

#### `firebase_app_check` - `v0.0.9`

 - **FEAT**: provide `androidDebugProvider` boolean for android debug provider & update app check example app ([#9412](https://github.com/firebase/flutterfire/issues/9412)). ([f1f26748](https://github.com/firebase/flutterfire/commit/f1f26748615c7c9d406e1d3d605e2987e1134ee7))

#### `firebase_auth` - `v3.11.1`

 - **FIX**: fix an iOS crash when using Sign In With Apple due to invalid return of nil instead of NSNull ([#9644](https://github.com/firebase/flutterfire/issues/9644)). ([3f76b53f](https://github.com/firebase/flutterfire/commit/3f76b53f375f4398652abfa7c9236571ee0bd87f))


## 2022-09-29

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`cloud_firestore` - `v3.5.0`](#cloud_firestore---v350)
 - [`cloud_firestore_odm` - `v1.0.0-dev.32`](#cloud_firestore_odm---v100-dev32)
 - [`cloud_firestore_odm_generator` - `v1.0.0-dev.32`](#cloud_firestore_odm_generator---v100-dev32)
 - [`firebase_app_check` - `v0.0.8`](#firebase_app_check---v008)
 - [`firebase_app_check_platform_interface` - `v0.0.5`](#firebase_app_check_platform_interface---v005)
 - [`firebase_app_check_web` - `v0.0.7`](#firebase_app_check_web---v007)
 - [`firebase_auth` - `v3.11.0`](#firebase_auth---v3110)
 - [`firebase_auth_platform_interface` - `v6.10.0`](#firebase_auth_platform_interface---v6100)
 - [`firebase_auth_web` - `v4.6.0`](#firebase_auth_web---v460)
 - [`firebase_core` - `v1.24.0`](#firebase_core---v1240)
 - [`firebase_core_web` - `v1.7.3`](#firebase_core_web---v173)
 - [`firebase_database` - `v9.1.6`](#firebase_database---v916)
 - [`flutterfire_ui` - `v0.4.3+11`](#flutterfire_ui---v04311)
 - [`cloud_functions` - `v3.3.9`](#cloud_functions---v339)
 - [`firebase_remote_config_web` - `v1.1.7`](#firebase_remote_config_web---v117)
 - [`firebase_remote_config_platform_interface` - `v1.1.18`](#firebase_remote_config_platform_interface---v1118)
 - [`firebase_in_app_messaging_platform_interface` - `v0.2.1+18`](#firebase_in_app_messaging_platform_interface---v02118)
 - [`firebase_crashlytics_platform_interface` - `v3.2.18`](#firebase_crashlytics_platform_interface---v3218)
 - [`firebase_ml_model_downloader_platform_interface` - `v0.1.1+18`](#firebase_ml_model_downloader_platform_interface---v01118)
 - [`firebase_crashlytics` - `v2.8.12`](#firebase_crashlytics---v2812)
 - [`firebase_in_app_messaging` - `v0.6.0+26`](#firebase_in_app_messaging---v06026)
 - [`firebase_remote_config` - `v2.0.19`](#firebase_remote_config---v2019)
 - [`firebase_ml_model_downloader` - `v0.1.1+9`](#firebase_ml_model_downloader---v0119)
 - [`_flutterfire_internals` - `v1.0.1`](#_flutterfire_internals---v101)
 - [`cloud_functions_web` - `v4.3.7`](#cloud_functions_web---v437)
 - [`cloud_functions_platform_interface` - `v5.1.18`](#cloud_functions_platform_interface---v5118)
 - [`firebase_performance_web` - `v0.1.1+7`](#firebase_performance_web---v0117)
 - [`firebase_storage_web` - `v3.3.8`](#firebase_storage_web---v338)
 - [`firebase_app_installations_web` - `v0.1.1+7`](#firebase_app_installations_web---v0117)
 - [`firebase_messaging_web` - `v3.1.6`](#firebase_messaging_web---v316)
 - [`firebase_analytics_web` - `v0.4.2+6`](#firebase_analytics_web---v0426)
 - [`firebase_storage_platform_interface` - `v4.1.18`](#firebase_storage_platform_interface---v4118)
 - [`firebase_performance_platform_interface` - `v0.1.1+18`](#firebase_performance_platform_interface---v01118)
 - [`firebase_dynamic_links_platform_interface` - `v0.2.3+14`](#firebase_dynamic_links_platform_interface---v02314)
 - [`firebase_app_installations_platform_interface` - `v0.1.1+18`](#firebase_app_installations_platform_interface---v01118)
 - [`firebase_messaging_platform_interface` - `v4.1.6`](#firebase_messaging_platform_interface---v416)
 - [`firebase_analytics_platform_interface` - `v3.3.6`](#firebase_analytics_platform_interface---v336)
 - [`firebase_performance` - `v0.8.3+2`](#firebase_performance---v0832)
 - [`firebase_storage` - `v10.3.10`](#firebase_storage---v10310)
 - [`firebase_dynamic_links` - `v4.3.9`](#firebase_dynamic_links---v439)
 - [`firebase_app_installations` - `v0.1.1+9`](#firebase_app_installations---v0119)
 - [`firebase_messaging` - `v13.0.4`](#firebase_messaging---v1304)
 - [`firebase_analytics` - `v9.3.7`](#firebase_analytics---v937)
 - [`cloud_firestore_web` - `v2.8.9`](#cloud_firestore_web---v289)
 - [`firebase_database_web` - `v0.2.1+8`](#firebase_database_web---v0218)
 - [`firebase_database_platform_interface` - `v0.2.2+6`](#firebase_database_platform_interface---v0226)
 - [`cloud_firestore_platform_interface` - `v5.7.6`](#cloud_firestore_platform_interface---v576)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flutterfire_ui` - `v0.4.3+11`
 - `cloud_functions` - `v3.3.9`
 - `firebase_remote_config_web` - `v1.1.7`
 - `firebase_remote_config_platform_interface` - `v1.1.18`
 - `firebase_in_app_messaging_platform_interface` - `v0.2.1+18`
 - `firebase_crashlytics_platform_interface` - `v3.2.18`
 - `firebase_ml_model_downloader_platform_interface` - `v0.1.1+18`
 - `firebase_crashlytics` - `v2.8.12`
 - `firebase_in_app_messaging` - `v0.6.0+26`
 - `firebase_remote_config` - `v2.0.19`
 - `firebase_ml_model_downloader` - `v0.1.1+9`
 - `_flutterfire_internals` - `v1.0.1`
 - `cloud_functions_web` - `v4.3.7`
 - `cloud_functions_platform_interface` - `v5.1.18`
 - `firebase_performance_web` - `v0.1.1+7`
 - `firebase_storage_web` - `v3.3.8`
 - `firebase_app_installations_web` - `v0.1.1+7`
 - `firebase_messaging_web` - `v3.1.6`
 - `firebase_analytics_web` - `v0.4.2+6`
 - `firebase_storage_platform_interface` - `v4.1.18`
 - `firebase_performance_platform_interface` - `v0.1.1+18`
 - `firebase_dynamic_links_platform_interface` - `v0.2.3+14`
 - `firebase_app_installations_platform_interface` - `v0.1.1+18`
 - `firebase_messaging_platform_interface` - `v4.1.6`
 - `firebase_analytics_platform_interface` - `v3.3.6`
 - `firebase_performance` - `v0.8.3+2`
 - `firebase_storage` - `v10.3.10`
 - `firebase_dynamic_links` - `v4.3.9`
 - `firebase_app_installations` - `v0.1.1+9`
 - `firebase_messaging` - `v13.0.4`
 - `firebase_analytics` - `v9.3.7`
 - `cloud_firestore_web` - `v2.8.9`
 - `firebase_database_web` - `v0.2.1+8`
 - `firebase_database_platform_interface` - `v0.2.2+6`
 - `cloud_firestore_platform_interface` - `v5.7.6`

---

#### `cloud_firestore` - `v3.5.0`

 - **FEAT**: add OAuth Access Token support to sign in with providers ([#9593](https://github.com/firebase/flutterfire/issues/9593)). ([cb6661bb](https://github.com/firebase/flutterfire/commit/cb6661bbc701031d6f920ace3a6efc8e8d56aa4c))
 - **FEAT**: Bump Firebase iOS SDK to `9.6.0` ([#9531](https://github.com/firebase/flutterfire/issues/9531)). ([2138f4aa](https://github.com/firebase/flutterfire/commit/2138f4aaaace51d5dce4809fb42e1e4ff20ed251))

#### `cloud_firestore_odm` - `v1.0.0-dev.32`

 - **FEAT**: Allow injecting the document ID in the ODM model ([#9600](https://github.com/firebase/flutterfire/issues/9600)). ([c7e93cfe](https://github.com/firebase/flutterfire/commit/c7e93cfec14e0e00bcabb232760ae5a968a1c2a1))

#### `cloud_firestore_odm_generator` - `v1.0.0-dev.32`

 - **FEAT**: Allow injecting the document ID in the ODM model ([#9600](https://github.com/firebase/flutterfire/issues/9600)). ([c7e93cfe](https://github.com/firebase/flutterfire/commit/c7e93cfec14e0e00bcabb232760ae5a968a1c2a1))

#### `firebase_app_check` - `v0.0.8`

 - **FEAT**: provide `androidDebugProvider` boolean for android debug provider & update app check example app ([#9412](https://github.com/firebase/flutterfire/issues/9412)). ([f1f26748](https://github.com/firebase/flutterfire/commit/f1f26748615c7c9d406e1d3d605e2987e1134ee7))

#### `firebase_app_check_platform_interface` - `v0.0.5`

 - **FEAT**: provide `androidDebugProvider` boolean for android debug provider & update app check example app ([#9412](https://github.com/firebase/flutterfire/issues/9412)). ([f1f26748](https://github.com/firebase/flutterfire/commit/f1f26748615c7c9d406e1d3d605e2987e1134ee7))

#### `firebase_app_check_web` - `v0.0.7`

 - **FEAT**: provide `androidDebugProvider` boolean for android debug provider & update app check example app ([#9412](https://github.com/firebase/flutterfire/issues/9412)). ([f1f26748](https://github.com/firebase/flutterfire/commit/f1f26748615c7c9d406e1d3d605e2987e1134ee7))

#### `firebase_auth` - `v3.11.0`

 - **FEAT**: add OAuth Access Token support to sign in with providers ([#9593](https://github.com/firebase/flutterfire/issues/9593)). ([cb6661bb](https://github.com/firebase/flutterfire/commit/cb6661bbc701031d6f920ace3a6efc8e8d56aa4c))
 - **FEAT**: add `linkWithRedirect` to the web ([#9580](https://github.com/firebase/flutterfire/issues/9580)). ([d834b90f](https://github.com/firebase/flutterfire/commit/d834b90f29fc1929a195d7d546170e4ea03c6ab1))

#### `firebase_auth_platform_interface` - `v6.10.0`

 - **FEAT**: add OAuth Access Token support to sign in with providers ([#9593](https://github.com/firebase/flutterfire/issues/9593)). ([cb6661bb](https://github.com/firebase/flutterfire/commit/cb6661bbc701031d6f920ace3a6efc8e8d56aa4c))
 - **FEAT**: add `linkWithRedirect` to the web ([#9580](https://github.com/firebase/flutterfire/issues/9580)). ([d834b90f](https://github.com/firebase/flutterfire/commit/d834b90f29fc1929a195d7d546170e4ea03c6ab1))

#### `firebase_auth_web` - `v4.6.0`

 - **FEAT**: add OAuth Access Token support to sign in with providers ([#9593](https://github.com/firebase/flutterfire/issues/9593)). ([cb6661bb](https://github.com/firebase/flutterfire/commit/cb6661bbc701031d6f920ace3a6efc8e8d56aa4c))
 - **FEAT**: add `linkWithRedirect` to the web ([#9580](https://github.com/firebase/flutterfire/issues/9580)). ([d834b90f](https://github.com/firebase/flutterfire/commit/d834b90f29fc1929a195d7d546170e4ea03c6ab1))

#### `firebase_core` - `v1.24.0`

 - **FEAT**: Bump Firebase iOS SDK to `9.6.0` ([#9531](https://github.com/firebase/flutterfire/issues/9531)). ([2138f4aa](https://github.com/firebase/flutterfire/commit/2138f4aaaace51d5dce4809fb42e1e4ff20ed251))

#### `firebase_core_web` - `v1.7.3`

 - **FIX**: explicitly set `null` value on Firestore data object property value ([#9599](https://github.com/firebase/flutterfire/issues/9599)). ([e61b6039](https://github.com/firebase/flutterfire/commit/e61b60390cfe8fc985203a4d3e3ed30eb8d020c6))

#### `firebase_database` - `v9.1.6`

 - **DOCS**: removed duplicate words in dart doc comment ([#9620](https://github.com/firebase/flutterfire/issues/9620)). ([cb980a6e](https://github.com/firebase/flutterfire/commit/cb980a6eb3cc08878ca6205e01e4d3e57add81cf))


## 2022-09-22

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`cloud_firestore_odm` - `v1.0.0-dev.31`](#cloud_firestore_odm---v100-dev31)
 - [`cloud_firestore_odm_generator` - `v1.0.0-dev.31`](#cloud_firestore_odm_generator---v100-dev31)
 - [`firebase_analytics` - `v9.3.6`](#firebase_analytics---v936)
 - [`firebase_auth` - `v3.10.0`](#firebase_auth---v3100)
 - [`firebase_auth_platform_interface` - `v6.9.0`](#firebase_auth_platform_interface---v690)
 - [`firebase_auth_web` - `v4.5.0`](#firebase_auth_web---v450)
 - [`firebase_core` - `v1.23.0`](#firebase_core---v1230)
 - [`flutterfire_ui` - `v0.4.3+10`](#flutterfire_ui---v04310)
 - [`cloud_functions` - `v3.3.8`](#cloud_functions---v338)
 - [`firebase_in_app_messaging` - `v0.6.0+25`](#firebase_in_app_messaging---v06025)
 - [`firebase_crashlytics_platform_interface` - `v3.2.17`](#firebase_crashlytics_platform_interface---v3217)
 - [`firebase_in_app_messaging_platform_interface` - `v0.2.1+17`](#firebase_in_app_messaging_platform_interface---v02117)
 - [`firebase_ml_model_downloader_platform_interface` - `v0.1.1+17`](#firebase_ml_model_downloader_platform_interface---v01117)
 - [`firebase_remote_config_web` - `v1.1.6`](#firebase_remote_config_web---v116)
 - [`firebase_remote_config_platform_interface` - `v1.1.17`](#firebase_remote_config_platform_interface---v1117)
 - [`firebase_crashlytics` - `v2.8.11`](#firebase_crashlytics---v2811)
 - [`firebase_remote_config` - `v2.0.18`](#firebase_remote_config---v2018)
 - [`firebase_ml_model_downloader` - `v0.1.1+8`](#firebase_ml_model_downloader---v0118)
 - [`cloud_functions_web` - `v4.3.6`](#cloud_functions_web---v436)
 - [`cloud_functions_platform_interface` - `v5.1.17`](#cloud_functions_platform_interface---v5117)
 - [`cloud_firestore` - `v3.4.9`](#cloud_firestore---v349)
 - [`firebase_performance_web` - `v0.1.1+6`](#firebase_performance_web---v0116)
 - [`firebase_database` - `v9.1.5`](#firebase_database---v915)
 - [`firebase_app_check_web` - `v0.0.6+6`](#firebase_app_check_web---v0066)
 - [`firebase_storage_web` - `v3.3.7`](#firebase_storage_web---v337)
 - [`firebase_app_installations_web` - `v0.1.1+6`](#firebase_app_installations_web---v0116)
 - [`firebase_messaging_web` - `v3.1.5`](#firebase_messaging_web---v315)
 - [`firebase_analytics_web` - `v0.4.2+5`](#firebase_analytics_web---v0425)
 - [`firebase_dynamic_links_platform_interface` - `v0.2.3+13`](#firebase_dynamic_links_platform_interface---v02313)
 - [`firebase_storage_platform_interface` - `v4.1.17`](#firebase_storage_platform_interface---v4117)
 - [`firebase_performance_platform_interface` - `v0.1.1+17`](#firebase_performance_platform_interface---v01117)
 - [`firebase_messaging_platform_interface` - `v4.1.5`](#firebase_messaging_platform_interface---v415)
 - [`firebase_app_installations_platform_interface` - `v0.1.1+17`](#firebase_app_installations_platform_interface---v01117)
 - [`firebase_analytics_platform_interface` - `v3.3.5`](#firebase_analytics_platform_interface---v335)
 - [`firebase_app_check_platform_interface` - `v0.0.4+17`](#firebase_app_check_platform_interface---v00417)
 - [`firebase_storage` - `v10.3.9`](#firebase_storage---v1039)
 - [`firebase_performance` - `v0.8.3+1`](#firebase_performance---v0831)
 - [`firebase_dynamic_links` - `v4.3.8`](#firebase_dynamic_links---v438)
 - [`firebase_app_installations` - `v0.1.1+8`](#firebase_app_installations---v0118)
 - [`firebase_messaging` - `v13.0.3`](#firebase_messaging---v1303)
 - [`firebase_app_check` - `v0.0.7+2`](#firebase_app_check---v0072)
 - [`cloud_firestore_web` - `v2.8.8`](#cloud_firestore_web---v288)
 - [`firebase_database_web` - `v0.2.1+7`](#firebase_database_web---v0217)
 - [`firebase_database_platform_interface` - `v0.2.2+5`](#firebase_database_platform_interface---v0225)
 - [`cloud_firestore_platform_interface` - `v5.7.5`](#cloud_firestore_platform_interface---v575)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flutterfire_ui` - `v0.4.3+10`
 - `cloud_functions` - `v3.3.8`
 - `firebase_in_app_messaging` - `v0.6.0+25`
 - `firebase_crashlytics_platform_interface` - `v3.2.17`
 - `firebase_in_app_messaging_platform_interface` - `v0.2.1+17`
 - `firebase_ml_model_downloader_platform_interface` - `v0.1.1+17`
 - `firebase_remote_config_web` - `v1.1.6`
 - `firebase_remote_config_platform_interface` - `v1.1.17`
 - `firebase_crashlytics` - `v2.8.11`
 - `firebase_remote_config` - `v2.0.18`
 - `firebase_ml_model_downloader` - `v0.1.1+8`
 - `cloud_functions_web` - `v4.3.6`
 - `cloud_functions_platform_interface` - `v5.1.17`
 - `cloud_firestore` - `v3.4.9`
 - `firebase_performance_web` - `v0.1.1+6`
 - `firebase_database` - `v9.1.5`
 - `firebase_app_check_web` - `v0.0.6+6`
 - `firebase_storage_web` - `v3.3.7`
 - `firebase_app_installations_web` - `v0.1.1+6`
 - `firebase_messaging_web` - `v3.1.5`
 - `firebase_analytics_web` - `v0.4.2+5`
 - `firebase_dynamic_links_platform_interface` - `v0.2.3+13`
 - `firebase_storage_platform_interface` - `v4.1.17`
 - `firebase_performance_platform_interface` - `v0.1.1+17`
 - `firebase_messaging_platform_interface` - `v4.1.5`
 - `firebase_app_installations_platform_interface` - `v0.1.1+17`
 - `firebase_analytics_platform_interface` - `v3.3.5`
 - `firebase_app_check_platform_interface` - `v0.0.4+17`
 - `firebase_storage` - `v10.3.9`
 - `firebase_performance` - `v0.8.3+1`
 - `firebase_dynamic_links` - `v4.3.8`
 - `firebase_app_installations` - `v0.1.1+8`
 - `firebase_messaging` - `v13.0.3`
 - `firebase_app_check` - `v0.0.7+2`
 - `cloud_firestore_web` - `v2.8.8`
 - `firebase_database_web` - `v0.2.1+7`
 - `firebase_database_platform_interface` - `v0.2.2+5`
 - `cloud_firestore_platform_interface` - `v5.7.5`

---

#### `cloud_firestore_odm` - `v1.0.0-dev.31`

 - **FIX**: handle query.orderBy(startAt:).orderBy() ([#9185](https://github.com/firebase/flutterfire/issues/9185)). ([62396e8a](https://github.com/firebase/flutterfire/commit/62396e8a4a229dfc096d6280964bb559c00b3511))

#### `cloud_firestore_odm_generator` - `v1.0.0-dev.31`

 - **FIX**: a false positive by checking that there are no prefix duplicates.  ([#9576](https://github.com/firebase/flutterfire/issues/9576)). ([d6f619c9](https://github.com/firebase/flutterfire/commit/d6f619c90fadb5057a8db1d69921cd4e2f5c1816))
 - **FIX**: handle query.orderBy(startAt:).orderBy() ([#9185](https://github.com/firebase/flutterfire/issues/9185)). ([62396e8a](https://github.com/firebase/flutterfire/commit/62396e8a4a229dfc096d6280964bb559c00b3511))

#### `firebase_analytics` - `v9.3.6`

 - **FIX**: suppress unchecked warnings that aren't necessary ([#9532](https://github.com/firebase/flutterfire/issues/9532)). ([3ebd4593](https://github.com/firebase/flutterfire/commit/3ebd4593d11fbbd359b8d514a9c0577654859992))

#### `firebase_auth` - `v3.10.0`

 - **FIX**: fix path of generated Pigeon files to prevent name collision ([#9569](https://github.com/firebase/flutterfire/issues/9569)). ([71bde27d](https://github.com/firebase/flutterfire/commit/71bde27d4e613096f121abb16d7ea8483c3fbcd8))
 - **FEAT**: add `reauthenticateWithProvider` ([#9570](https://github.com/firebase/flutterfire/issues/9570)). ([dad6b481](https://github.com/firebase/flutterfire/commit/dad6b4813c682e35315dda3965ea8aaf5ba030e8))

#### `firebase_auth_platform_interface` - `v6.9.0`

 - **FIX**: fix path of generated Pigeon files to prevent name collision ([#9569](https://github.com/firebase/flutterfire/issues/9569)). ([71bde27d](https://github.com/firebase/flutterfire/commit/71bde27d4e613096f121abb16d7ea8483c3fbcd8))
 - **FEAT**: add `reauthenticateWithProvider` ([#9570](https://github.com/firebase/flutterfire/issues/9570)). ([dad6b481](https://github.com/firebase/flutterfire/commit/dad6b4813c682e35315dda3965ea8aaf5ba030e8))

#### `firebase_auth_web` - `v4.5.0`

 - **FEAT**: add `reauthenticateWithProvider` ([#9570](https://github.com/firebase/flutterfire/issues/9570)). ([dad6b481](https://github.com/firebase/flutterfire/commit/dad6b4813c682e35315dda3965ea8aaf5ba030e8))

#### `firebase_core` - `v1.23.0`

 - **FEAT**: Bump Firebase android SDK to 30.5.0 ([#9573](https://github.com/firebase/flutterfire/issues/9573)). ([3ec750e1](https://github.com/firebase/flutterfire/commit/3ec750e1612671527fe7c0e576ca900821c1535b))
 - **DOCS**: update inline documentation on `initializeApp()` behaviour ([#9431](https://github.com/firebase/flutterfire/issues/9431)). ([3af5b676](https://github.com/firebase/flutterfire/commit/3af5b67664149b54ec73b328a04d94c06f389221))


## 2022-09-15

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`cloud_firestore` - `v3.4.8`](#cloud_firestore---v348)
 - [`cloud_firestore_odm` - `v1.0.0-dev.30`](#cloud_firestore_odm---v100-dev30)
 - [`cloud_firestore_odm_generator` - `v1.0.0-dev.30`](#cloud_firestore_odm_generator---v100-dev30)
 - [`firebase_analytics` - `v9.3.5`](#firebase_analytics---v935)
 - [`firebase_auth` - `v3.9.0`](#firebase_auth---v390)
 - [`firebase_auth_platform_interface` - `v6.8.0`](#firebase_auth_platform_interface---v680)
 - [`firebase_messaging` - `v13.0.2`](#firebase_messaging---v1302)
 - [`flutterfire_ui` - `v0.4.3+9`](#flutterfire_ui---v0439)
 - [`firebase_auth_web` - `v4.4.1`](#firebase_auth_web---v441)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flutterfire_ui` - `v0.4.3+9`
 - `firebase_auth_web` - `v4.4.1`

---

#### `cloud_firestore` - `v3.4.8`

 - **FIX**: fix `queryGet()` & `namedQueryGet()`. Check if `query` is `[NSNull null]` value ([#9410](https://github.com/firebase/flutterfire/issues/9410)). ([ae035fe2](https://github.com/firebase/flutterfire/commit/ae035fe2b060264153386ae5c2a1eb90c22e90f3))

#### `cloud_firestore_odm` - `v1.0.0-dev.30`

 - **FEAT**: add support for specifying class name prefix ([#9453](https://github.com/firebase/flutterfire/issues/9453)). ([49921a43](https://github.com/firebase/flutterfire/commit/49921a4362c5965d2efeed17eb73775302007ea8))

#### `cloud_firestore_odm_generator` - `v1.0.0-dev.30`

 - **FEAT**: add support for specifying class name prefix ([#9453](https://github.com/firebase/flutterfire/issues/9453)). ([49921a43](https://github.com/firebase/flutterfire/commit/49921a4362c5965d2efeed17eb73775302007ea8))

#### `firebase_analytics` - `v9.3.5`

 - **REFACTOR**: deprecate `signInWithAuthProvider` in favor of `signInWithProvider` ([#9542](https://github.com/firebase/flutterfire/issues/9542)). ([ca340ea1](https://github.com/firebase/flutterfire/commit/ca340ea19c8dbb340f083e48cf1b0de36f7d64c4))

#### `firebase_auth` - `v3.9.0`

 - **REFACTOR**: deprecate `signInWithAuthProvider` in favor of `signInWithProvider` ([#9542](https://github.com/firebase/flutterfire/issues/9542)). ([ca340ea1](https://github.com/firebase/flutterfire/commit/ca340ea19c8dbb340f083e48cf1b0de36f7d64c4))
 - **FEAT**: add `linkWithProvider` to support for linking auth providers ([#9535](https://github.com/firebase/flutterfire/issues/9535)). ([1ac14fb1](https://github.com/firebase/flutterfire/commit/1ac14fb147f83cf5c7874004a9dc61838dce8da8))

#### `firebase_auth_platform_interface` - `v6.8.0`

 - **REFACTOR**: deprecate `signInWithAuthProvider` in favor of `signInWithProvider` ([#9542](https://github.com/firebase/flutterfire/issues/9542)). ([ca340ea1](https://github.com/firebase/flutterfire/commit/ca340ea19c8dbb340f083e48cf1b0de36f7d64c4))
 - **FEAT**: add `linkWithProvider` to support for linking auth providers ([#9535](https://github.com/firebase/flutterfire/issues/9535)). ([1ac14fb1](https://github.com/firebase/flutterfire/commit/1ac14fb147f83cf5c7874004a9dc61838dce8da8))

#### `firebase_messaging` - `v13.0.2`

 - **DOCS**: update docs to use `@pragma('vm:entry-point')` annotation for messaging background handler ([#9494](https://github.com/firebase/flutterfire/issues/9494)). ([27a7f44e](https://github.com/firebase/flutterfire/commit/27a7f44e02f2ed533e0249622afdd0a421261385))


## 2022-09-08

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`cloud_firestore_odm` - `v1.0.0-dev.29`](#cloud_firestore_odm---v100-dev29)
 - [`cloud_firestore_odm_generator` - `v1.0.0-dev.29`](#cloud_firestore_odm_generator---v100-dev29)
 - [`firebase_auth` - `v3.8.0`](#firebase_auth---v380)
 - [`firebase_auth_platform_interface` - `v6.7.0`](#firebase_auth_platform_interface---v670)
 - [`firebase_auth_web` - `v4.4.0`](#firebase_auth_web---v440)
 - [`firebase_core` - `v1.22.0`](#firebase_core---v1220)
 - [`firebase_crashlytics` - `v2.8.10`](#firebase_crashlytics---v2810)
 - [`firebase_messaging` - `v13.0.1`](#firebase_messaging---v1301)
 - [`firebase_performance` - `v0.8.3`](#firebase_performance---v083)
 - [`flutterfire_ui` - `v0.4.3+8`](#flutterfire_ui---v0438)
 - [`firebase_crashlytics_platform_interface` - `v3.2.16`](#firebase_crashlytics_platform_interface---v3216)
 - [`firebase_remote_config` - `v2.0.17`](#firebase_remote_config---v2017)
 - [`firebase_in_app_messaging_platform_interface` - `v0.2.1+16`](#firebase_in_app_messaging_platform_interface---v02116)
 - [`firebase_in_app_messaging` - `v0.6.0+24`](#firebase_in_app_messaging---v06024)
 - [`firebase_remote_config_web` - `v1.1.5`](#firebase_remote_config_web---v115)
 - [`firebase_remote_config_platform_interface` - `v1.1.16`](#firebase_remote_config_platform_interface---v1116)
 - [`firebase_database` - `v9.1.4`](#firebase_database---v914)
 - [`firebase_database_web` - `v0.2.1+6`](#firebase_database_web---v0216)
 - [`firebase_database_platform_interface` - `v0.2.2+4`](#firebase_database_platform_interface---v0224)
 - [`firebase_dynamic_links` - `v4.3.7`](#firebase_dynamic_links---v437)
 - [`firebase_dynamic_links_platform_interface` - `v0.2.3+12`](#firebase_dynamic_links_platform_interface---v02312)
 - [`cloud_firestore` - `v3.4.7`](#cloud_firestore---v347)
 - [`cloud_firestore_platform_interface` - `v5.7.4`](#cloud_firestore_platform_interface---v574)
 - [`cloud_firestore_web` - `v2.8.7`](#cloud_firestore_web---v287)
 - [`firebase_app_installations_web` - `v0.1.1+5`](#firebase_app_installations_web---v0115)
 - [`firebase_app_installations` - `v0.1.1+7`](#firebase_app_installations---v0117)
 - [`firebase_app_installations_platform_interface` - `v0.1.1+16`](#firebase_app_installations_platform_interface---v01116)
 - [`firebase_messaging_web` - `v3.1.4`](#firebase_messaging_web---v314)
 - [`firebase_analytics_platform_interface` - `v3.3.4`](#firebase_analytics_platform_interface---v334)
 - [`firebase_messaging_platform_interface` - `v4.1.4`](#firebase_messaging_platform_interface---v414)
 - [`firebase_ml_model_downloader` - `v0.1.1+7`](#firebase_ml_model_downloader---v0117)
 - [`firebase_ml_model_downloader_platform_interface` - `v0.1.1+16`](#firebase_ml_model_downloader_platform_interface---v01116)
 - [`firebase_analytics` - `v9.3.4`](#firebase_analytics---v934)
 - [`firebase_app_check_platform_interface` - `v0.0.4+16`](#firebase_app_check_platform_interface---v00416)
 - [`firebase_analytics_web` - `v0.4.2+4`](#firebase_analytics_web---v0424)
 - [`firebase_app_check` - `v0.0.7+1`](#firebase_app_check---v0071)
 - [`firebase_app_check_web` - `v0.0.6+5`](#firebase_app_check_web---v0065)
 - [`cloud_functions_web` - `v4.3.5`](#cloud_functions_web---v435)
 - [`cloud_functions` - `v3.3.7`](#cloud_functions---v337)
 - [`cloud_functions_platform_interface` - `v5.1.16`](#cloud_functions_platform_interface---v5116)
 - [`firebase_storage_web` - `v3.3.6`](#firebase_storage_web---v336)
 - [`firebase_storage_platform_interface` - `v4.1.16`](#firebase_storage_platform_interface---v4116)
 - [`firebase_storage` - `v10.3.8`](#firebase_storage---v1038)
 - [`firebase_performance_web` - `v0.1.1+5`](#firebase_performance_web---v0115)
 - [`firebase_performance_platform_interface` - `v0.1.1+16`](#firebase_performance_platform_interface---v01116)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flutterfire_ui` - `v0.4.3+8`
 - `firebase_crashlytics_platform_interface` - `v3.2.16`
 - `firebase_remote_config` - `v2.0.17`
 - `firebase_in_app_messaging_platform_interface` - `v0.2.1+16`
 - `firebase_in_app_messaging` - `v0.6.0+24`
 - `firebase_remote_config_web` - `v1.1.5`
 - `firebase_remote_config_platform_interface` - `v1.1.16`
 - `firebase_database` - `v9.1.4`
 - `firebase_database_web` - `v0.2.1+6`
 - `firebase_database_platform_interface` - `v0.2.2+4`
 - `firebase_dynamic_links` - `v4.3.7`
 - `firebase_dynamic_links_platform_interface` - `v0.2.3+12`
 - `cloud_firestore` - `v3.4.7`
 - `cloud_firestore_platform_interface` - `v5.7.4`
 - `cloud_firestore_web` - `v2.8.7`
 - `firebase_app_installations_web` - `v0.1.1+5`
 - `firebase_app_installations` - `v0.1.1+7`
 - `firebase_app_installations_platform_interface` - `v0.1.1+16`
 - `firebase_messaging_web` - `v3.1.4`
 - `firebase_analytics_platform_interface` - `v3.3.4`
 - `firebase_messaging_platform_interface` - `v4.1.4`
 - `firebase_ml_model_downloader` - `v0.1.1+7`
 - `firebase_ml_model_downloader_platform_interface` - `v0.1.1+16`
 - `firebase_analytics` - `v9.3.4`
 - `firebase_app_check_platform_interface` - `v0.0.4+16`
 - `firebase_analytics_web` - `v0.4.2+4`
 - `firebase_app_check` - `v0.0.7+1`
 - `firebase_app_check_web` - `v0.0.6+5`
 - `cloud_functions_web` - `v4.3.5`
 - `cloud_functions` - `v3.3.7`
 - `cloud_functions_platform_interface` - `v5.1.16`
 - `firebase_storage_web` - `v3.3.6`
 - `firebase_storage_platform_interface` - `v4.1.16`
 - `firebase_storage` - `v10.3.8`
 - `firebase_performance_web` - `v0.1.1+5`
 - `firebase_performance_platform_interface` - `v0.1.1+16`

---

#### `cloud_firestore_odm` - `v1.0.0-dev.29`

 - **FEAT**: Add support using Freezed classes as collection models ([#9483](https://github.com/firebase/flutterfire/issues/9483)). ([ce238f71](https://github.com/firebase/flutterfire/commit/ce238f713b250f523890b9e7e42d395f433ed80f))

#### `cloud_firestore_odm_generator` - `v1.0.0-dev.29`

 - **FIX**: bump minimum analyzer version ([#9493](https://github.com/firebase/flutterfire/issues/9493)). ([5137a646](https://github.com/firebase/flutterfire/commit/5137a6469fb57fb003757459222cb6c4e39fb0f8))
 - **FEAT**: Add support using Freezed classes as collection models ([#9483](https://github.com/firebase/flutterfire/issues/9483)). ([ce238f71](https://github.com/firebase/flutterfire/commit/ce238f713b250f523890b9e7e42d395f433ed80f))

#### `firebase_auth` - `v3.8.0`

 - **FIX**: remove default scopes on iOS for Sign in With Apple ([#9477](https://github.com/firebase/flutterfire/issues/9477)). ([3fe02b29](https://github.com/firebase/flutterfire/commit/3fe02b2937135ea6d576c7e445da5f4266ff0fdf))
 - **FEAT**: add Twitter login for Android, iOS and Web ([#9421](https://github.com/firebase/flutterfire/issues/9421)). ([0bc6e6d5](https://github.com/firebase/flutterfire/commit/0bc6e6d5333e6be0d5749a083206f3f5bb79a7ba))
 - **FEAT**: add Yahoo as provider for iOS, Android and Web ([#9443](https://github.com/firebase/flutterfire/issues/9443)). ([6c3108a7](https://github.com/firebase/flutterfire/commit/6c3108a767aca3b1a844b2b5da04b2da45bc9fbd))
 - **DOCS**: fix typo "apperance" in `platform_interface_firebase_auth.dart` ([#9472](https://github.com/firebase/flutterfire/issues/9472)). ([323b917b](https://github.com/firebase/flutterfire/commit/323b917b5eecf0e5161a61c66f6cabac5b23e1b8))

#### `firebase_auth_platform_interface` - `v6.7.0`

 - **FIX**: fix enrollementTimestamp parsing on Web ([#9440](https://github.com/firebase/flutterfire/issues/9440)). ([639cab7b](https://github.com/firebase/flutterfire/commit/639cab7b84aa33cc1dda144fc89db2236a1945b2))
 - **FEAT**: add Twitter login for Android, iOS and Web ([#9421](https://github.com/firebase/flutterfire/issues/9421)). ([0bc6e6d5](https://github.com/firebase/flutterfire/commit/0bc6e6d5333e6be0d5749a083206f3f5bb79a7ba))
 - **FEAT**: add Yahoo as provider for iOS, Android and Web ([#9443](https://github.com/firebase/flutterfire/issues/9443)). ([6c3108a7](https://github.com/firebase/flutterfire/commit/6c3108a767aca3b1a844b2b5da04b2da45bc9fbd))
 - **DOCS**: fix typo "apperance" in `platform_interface_firebase_auth.dart` ([#9472](https://github.com/firebase/flutterfire/issues/9472)). ([323b917b](https://github.com/firebase/flutterfire/commit/323b917b5eecf0e5161a61c66f6cabac5b23e1b8))

#### `firebase_auth_web` - `v4.4.0`

 - **FIX**: fix enrollementTimestamp parsing on Web ([#9440](https://github.com/firebase/flutterfire/issues/9440)). ([639cab7b](https://github.com/firebase/flutterfire/commit/639cab7b84aa33cc1dda144fc89db2236a1945b2))
 - **FEAT**: add Yahoo as provider for iOS, Android and Web ([#9443](https://github.com/firebase/flutterfire/issues/9443)). ([6c3108a7](https://github.com/firebase/flutterfire/commit/6c3108a767aca3b1a844b2b5da04b2da45bc9fbd))

#### `firebase_core` - `v1.22.0`

 - **FEAT**: Bump Firebase iOS SDK to 9.5.0 ([#9492](https://github.com/firebase/flutterfire/issues/9492)). ([d246ba2a](https://github.com/firebase/flutterfire/commit/d246ba2aeec3da0bf5e2b4171ea2d1ec67618226))

#### `firebase_crashlytics` - `v2.8.10`

 - **FIX**: Replace null or empty stack traces with the current stack trace ([#9490](https://github.com/firebase/flutterfire/issues/9490)). ([c54a95f3](https://github.com/firebase/flutterfire/commit/c54a95f365c5a61d2df52fb89467ab6103aa0146))

#### `firebase_messaging` - `v13.0.1`

 - **FIX**: ensure only messaging permission request is processed ([#9486](https://github.com/firebase/flutterfire/issues/9486)). ([5b31e71b](https://github.com/firebase/flutterfire/commit/5b31e71b6cbca0e6a149482436e00598f4eaa2de))

#### `firebase_performance` - `v0.8.3`

 - **FEAT**: Bump Firebase iOS SDK to 9.5.0 ([#9492](https://github.com/firebase/flutterfire/issues/9492)). ([d246ba2a](https://github.com/firebase/flutterfire/commit/d246ba2aeec3da0bf5e2b4171ea2d1ec67618226))


## 2022-08-25

### Changes

---

Packages with breaking changes:

 - [`firebase_messaging` - `v13.0.0`](#firebase_messaging---v1300)

Packages with other changes:

 - [`firebase_analytics_web` - `v0.4.2+3`](#firebase_analytics_web---v0423)
 - [`firebase_app_check` - `v0.0.7`](#firebase_app_check---v007)
 - [`firebase_auth` - `v3.7.0`](#firebase_auth---v370)
 - [`firebase_auth_platform_interface` - `v6.6.0`](#firebase_auth_platform_interface---v660)
 - [`firebase_auth_web` - `v4.3.0`](#firebase_auth_web---v430)
 - [`firebase_core_platform_interface` - `v4.5.1`](#firebase_core_platform_interface---v451)
 - [`firebase_crashlytics` - `v2.8.9`](#firebase_crashlytics---v289)
 - [`firebase_crashlytics_platform_interface` - `v3.2.15`](#firebase_crashlytics_platform_interface---v3215)
 - [`firebase_remote_config` - `v2.0.16`](#firebase_remote_config---v2016)
 - [`firebase_analytics` - `v9.3.3`](#firebase_analytics---v933)
 - [`flutterfire_ui` - `v0.4.3+7`](#flutterfire_ui---v0437)
 - [`firebase_in_app_messaging` - `v0.6.0+23`](#firebase_in_app_messaging---v06023)
 - [`firebase_dynamic_links` - `v4.3.6`](#firebase_dynamic_links---v436)
 - [`firebase_database` - `v9.1.3`](#firebase_database---v913)
 - [`cloud_firestore` - `v3.4.6`](#cloud_firestore---v346)
 - [`firebase_app_installations` - `v0.1.1+6`](#firebase_app_installations---v0116)
 - [`firebase_ml_model_downloader` - `v0.1.1+6`](#firebase_ml_model_downloader---v0116)
 - [`cloud_functions` - `v3.3.6`](#cloud_functions---v336)
 - [`firebase_core` - `v1.21.1`](#firebase_core---v1211)
 - [`firebase_storage` - `v10.3.7`](#firebase_storage---v1037)
 - [`firebase_core_web` - `v1.7.2`](#firebase_core_web---v172)
 - [`firebase_performance` - `v0.8.2+4`](#firebase_performance---v0824)
 - [`cloud_firestore_odm` - `v1.0.0-dev.28`](#cloud_firestore_odm---v100-dev28)
 - [`firebase_in_app_messaging_platform_interface` - `v0.2.1+15`](#firebase_in_app_messaging_platform_interface---v02115)
 - [`firebase_remote_config_web` - `v1.1.4`](#firebase_remote_config_web---v114)
 - [`firebase_remote_config_platform_interface` - `v1.1.15`](#firebase_remote_config_platform_interface---v1115)
 - [`firebase_database_platform_interface` - `v0.2.2+3`](#firebase_database_platform_interface---v0223)
 - [`firebase_database_web` - `v0.2.1+5`](#firebase_database_web---v0215)
 - [`firebase_dynamic_links_platform_interface` - `v0.2.3+11`](#firebase_dynamic_links_platform_interface---v02311)
 - [`cloud_firestore_web` - `v2.8.6`](#cloud_firestore_web---v286)
 - [`cloud_firestore_platform_interface` - `v5.7.3`](#cloud_firestore_platform_interface---v573)
 - [`firebase_app_installations_web` - `v0.1.1+4`](#firebase_app_installations_web---v0114)
 - [`firebase_messaging_platform_interface` - `v4.1.3`](#firebase_messaging_platform_interface---v413)
 - [`firebase_app_check_platform_interface` - `v0.0.4+15`](#firebase_app_check_platform_interface---v00415)
 - [`firebase_messaging_web` - `v3.1.3`](#firebase_messaging_web---v313)
 - [`firebase_app_check_web` - `v0.0.6+4`](#firebase_app_check_web---v0064)
 - [`firebase_app_installations_platform_interface` - `v0.1.1+15`](#firebase_app_installations_platform_interface---v01115)
 - [`firebase_ml_model_downloader_platform_interface` - `v0.1.1+15`](#firebase_ml_model_downloader_platform_interface---v01115)
 - [`cloud_functions_web` - `v4.3.4`](#cloud_functions_web---v434)
 - [`firebase_analytics_platform_interface` - `v3.3.3`](#firebase_analytics_platform_interface---v333)
 - [`cloud_functions_platform_interface` - `v5.1.15`](#cloud_functions_platform_interface---v5115)
 - [`firebase_storage_web` - `v3.3.5`](#firebase_storage_web---v335)
 - [`firebase_storage_platform_interface` - `v4.1.15`](#firebase_storage_platform_interface---v4115)
 - [`firebase_performance_platform_interface` - `v0.1.1+15`](#firebase_performance_platform_interface---v01115)
 - [`firebase_performance_web` - `v0.1.1+4`](#firebase_performance_web---v0114)
 - [`cloud_firestore_odm_generator` - `v1.0.0-dev.28`](#cloud_firestore_odm_generator---v100-dev28)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `firebase_analytics` - `v9.3.3`
 - `flutterfire_ui` - `v0.4.3+7`
 - `firebase_crashlytics` - `v2.8.9`
 - `firebase_crashlytics_platform_interface` - `v3.2.15`
 - `firebase_dynamic_links` - `v4.3.6`
 - `firebase_database` - `v9.1.3`
 - `cloud_firestore` - `v3.4.6`
 - `firebase_app_installations` - `v0.1.1+6`
 - `firebase_ml_model_downloader` - `v0.1.1+6`
 - `cloud_functions` - `v3.3.6`
 - `firebase_core` - `v1.21.1`
 - `firebase_storage` - `v10.3.7`
 - `firebase_core_web` - `v1.7.2`
 - `firebase_performance` - `v0.8.2+4`
 - `cloud_firestore_odm` - `v1.0.0-dev.28`
 - `firebase_in_app_messaging_platform_interface` - `v0.2.1+15`
 - `firebase_remote_config_web` - `v1.1.4`
 - `firebase_remote_config_platform_interface` - `v1.1.15`
 - `firebase_database_platform_interface` - `v0.2.2+3`
 - `firebase_database_web` - `v0.2.1+5`
 - `firebase_dynamic_links_platform_interface` - `v0.2.3+11`
 - `cloud_firestore_web` - `v2.8.6`
 - `cloud_firestore_platform_interface` - `v5.7.3`
 - `firebase_app_installations_web` - `v0.1.1+4`
 - `firebase_messaging_platform_interface` - `v4.1.3`
 - `firebase_app_check_platform_interface` - `v0.0.4+15`
 - `firebase_messaging_web` - `v3.1.3`
 - `firebase_app_check_web` - `v0.0.6+4`
 - `firebase_app_installations_platform_interface` - `v0.1.1+15`
 - `firebase_ml_model_downloader_platform_interface` - `v0.1.1+15`
 - `cloud_functions_web` - `v4.3.4`
 - `firebase_analytics_platform_interface` - `v3.3.3`
 - `cloud_functions_platform_interface` - `v5.1.15`
 - `firebase_storage_web` - `v3.3.5`
 - `firebase_storage_platform_interface` - `v4.1.15`
 - `firebase_performance_platform_interface` - `v0.1.1+15`
 - `firebase_performance_web` - `v0.1.1+4`
 - `cloud_firestore_odm_generator` - `v1.0.0-dev.28`

---

#### `firebase_messaging` - `v13.0.0`

 - **BREAKING** **FEAT**: android 13 notifications permission request ([#9348](https://github.com/firebase/flutterfire/issues/9348)). ([43b3b06b](https://github.com/firebase/flutterfire/commit/43b3b06b64739658f79c994110654f5a56abca05))
   `firebase_messaging` now includes this permission: `Manifest.permission.POST_NOTIFICATIONS` in its `AndroidManifest.xml` file which requires updating your `android/app/build.gradle` to target API level 33.

#### `firebase_analytics_web` - `v0.4.2+3`

 - **FIX**: `setCurrentScreen()` API is now obsolete, using `logEvent()` instead ([#9397](https://github.com/firebase/flutterfire/issues/9397)). ([490ef204](https://github.com/firebase/flutterfire/commit/490ef204b9873fca994f1a69ddf7962e6d735c4b))

#### `firebase_app_check` - `v0.0.7`

 - **FEAT**: update the example app with webRecaptcha in activate button ([#9373](https://github.com/firebase/flutterfire/issues/9373)). ([1ff76c1b](https://github.com/firebase/flutterfire/commit/1ff76c1b87b623ff21c921d6a6cc2c586cf43ac3))
 - **REFACTOR**: update deprecated `Tasks.call()` to `TaskCompletionSource` API ([#9404](https://github.com/firebase/flutterfire/pull/9404)). ([837d68ea](https://github.com/firebase/flutterfire/commit/5aa9f665e70297fecb88bd0fda5445753470660f))

#### `firebase_auth` - `v3.7.0`

 - **FEAT**: add Microsoft login for Android, iOS and Web ([#9415](https://github.com/firebase/flutterfire/issues/9415)). ([1610ce8a](https://github.com/firebase/flutterfire/commit/1610ce8ac96d6da202ef014e9a3dfeb4acfacec9))
 - **FEAT**: add Sign in with Apple directly in Firebase Auth for Android, iOS 13+ and Web ([#9408](https://github.com/firebase/flutterfire/issues/9408)). ([da36b986](https://github.com/firebase/flutterfire/commit/da36b9861b7d635382705b4893eed85fd672125c))

#### `firebase_auth_platform_interface` - `v6.6.0`

 - **FEAT**: add Microsoft login for Android, iOS and Web ([#9415](https://github.com/firebase/flutterfire/issues/9415)). ([1610ce8a](https://github.com/firebase/flutterfire/commit/1610ce8ac96d6da202ef014e9a3dfeb4acfacec9))
 - **FEAT**: add Sign in with Apple directly in Firebase Auth for Android, iOS 13+ and Web ([#9408](https://github.com/firebase/flutterfire/issues/9408)). ([da36b986](https://github.com/firebase/flutterfire/commit/da36b9861b7d635382705b4893eed85fd672125c))

#### `firebase_auth_web` - `v4.3.0`

 - **FEAT**: add Microsoft login for Android, iOS and Web ([#9415](https://github.com/firebase/flutterfire/issues/9415)). ([1610ce8a](https://github.com/firebase/flutterfire/commit/1610ce8ac96d6da202ef014e9a3dfeb4acfacec9))
 - **FEAT**: add Sign in with Apple directly in Firebase Auth for Android, iOS 13+ and Web ([#9408](https://github.com/firebase/flutterfire/issues/9408)). ([da36b986](https://github.com/firebase/flutterfire/commit/da36b9861b7d635382705b4893eed85fd672125c))

#### `firebase_core_platform_interface` - `v4.5.1`

 - **FIX**: Prepare for fix to https://github.com/flutter/flutter/issues/109339. ([#9364](https://github.com/firebase/flutterfire/issues/9364)). ([7418dfd9](https://github.com/firebase/flutterfire/commit/7418dfd91c4fc7982c6bc6b1e8de80f9bccd575b))

	#### `firebase_in_app_messaging` - `v0.6.0+23`

 - **REFACTOR**: update deprecated `Tasks.call()` to `TaskCompletionSource` API ([#9407](https://github.com/firebase/flutterfire/pull/9407)). ([837d68ea](https://github.com/firebase/flutterfire/commit/bb9b3b23c683d28730a1952f54384caed78674d7))

#### `firebase_remote_config` - `v2.0.16`

 - **REFACTOR**: update deprecated `Tasks.call()` to `TaskCompletionSource` API ([#9405](https://github.com/firebase/flutterfire/issues/9405)). ([837d68ea](https://github.com/firebase/flutterfire/commit/837d68ea60649fa1fb1c7f8254e4ae67874e9bf2))


## 2022-08-18

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`cloud_firestore_odm_generator` - `v1.0.0-dev.27`](#cloud_firestore_odm_generator---v100-dev27)
 - [`firebase_auth` - `v3.6.4`](#firebase_auth---v364)
 - [`firebase_auth_platform_interface` - `v6.5.4`](#firebase_auth_platform_interface---v654)
 - [`firebase_core` - `v1.21.0`](#firebase_core---v1210)
 - [`flutterfire_ui` - `v0.4.3+6`](#flutterfire_ui---v0436)
 - [`firebase_auth_web` - `v4.2.4`](#firebase_auth_web---v424)
 - [`firebase_crashlytics_platform_interface` - `v3.2.14`](#firebase_crashlytics_platform_interface---v3214)
 - [`firebase_in_app_messaging` - `v0.6.0+22`](#firebase_in_app_messaging---v06022)
 - [`firebase_database_web` - `v0.2.1+4`](#firebase_database_web---v0214)
 - [`firebase_database` - `v9.1.2`](#firebase_database---v912)
 - [`firebase_remote_config_web` - `v1.1.3`](#firebase_remote_config_web---v113)
 - [`firebase_in_app_messaging_platform_interface` - `v0.2.1+14`](#firebase_in_app_messaging_platform_interface---v02114)
 - [`firebase_remote_config` - `v2.0.15`](#firebase_remote_config---v2015)
 - [`firebase_crashlytics` - `v2.8.8`](#firebase_crashlytics---v288)
 - [`firebase_remote_config_platform_interface` - `v1.1.14`](#firebase_remote_config_platform_interface---v1114)
 - [`firebase_database_platform_interface` - `v0.2.2+2`](#firebase_database_platform_interface---v0222)
 - [`firebase_dynamic_links` - `v4.3.5`](#firebase_dynamic_links---v435)
 - [`firebase_dynamic_links_platform_interface` - `v0.2.3+10`](#firebase_dynamic_links_platform_interface---v02310)
 - [`cloud_firestore_web` - `v2.8.5`](#cloud_firestore_web---v285)
 - [`firebase_app_installations_web` - `v0.1.1+3`](#firebase_app_installations_web---v0113)
 - [`firebase_app_installations` - `v0.1.1+5`](#firebase_app_installations---v0115)
 - [`cloud_firestore` - `v3.4.5`](#cloud_firestore---v345)
 - [`firebase_app_installations_platform_interface` - `v0.1.1+14`](#firebase_app_installations_platform_interface---v01114)
 - [`cloud_firestore_platform_interface` - `v5.7.2`](#cloud_firestore_platform_interface---v572)
 - [`firebase_messaging_web` - `v3.1.2`](#firebase_messaging_web---v312)
 - [`firebase_messaging` - `v12.0.3`](#firebase_messaging---v1203)
 - [`firebase_messaging_platform_interface` - `v4.1.2`](#firebase_messaging_platform_interface---v412)
 - [`firebase_analytics_platform_interface` - `v3.3.2`](#firebase_analytics_platform_interface---v332)
 - [`firebase_analytics` - `v9.3.2`](#firebase_analytics---v932)
 - [`firebase_analytics_web` - `v0.4.2+2`](#firebase_analytics_web---v0422)
 - [`cloud_functions_web` - `v4.3.3`](#cloud_functions_web---v433)
 - [`firebase_app_check` - `v0.0.6+20`](#firebase_app_check---v00620)
 - [`cloud_functions` - `v3.3.5`](#cloud_functions---v335)
 - [`cloud_functions_platform_interface` - `v5.1.14`](#cloud_functions_platform_interface---v5114)
 - [`firebase_ml_model_downloader` - `v0.1.1+5`](#firebase_ml_model_downloader---v0115)
 - [`firebase_app_check_platform_interface` - `v0.0.4+14`](#firebase_app_check_platform_interface---v00414)
 - [`firebase_storage_web` - `v3.3.4`](#firebase_storage_web---v334)
 - [`firebase_ml_model_downloader_platform_interface` - `v0.1.1+14`](#firebase_ml_model_downloader_platform_interface---v01114)
 - [`firebase_storage_platform_interface` - `v4.1.14`](#firebase_storage_platform_interface---v4114)
 - [`firebase_storage` - `v10.3.6`](#firebase_storage---v1036)
 - [`firebase_app_check_web` - `v0.0.6+3`](#firebase_app_check_web---v0063)
 - [`firebase_performance` - `v0.8.2+3`](#firebase_performance---v0823)
 - [`firebase_performance_platform_interface` - `v0.1.1+14`](#firebase_performance_platform_interface---v01114)
 - [`firebase_performance_web` - `v0.1.1+3`](#firebase_performance_web---v0113)
 - [`cloud_firestore_odm` - `v1.0.0-dev.27`](#cloud_firestore_odm---v100-dev27)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flutterfire_ui` - `v0.4.3+6`
 - `firebase_auth_web` - `v4.2.4`
 - `firebase_crashlytics_platform_interface` - `v3.2.14`
 - `firebase_in_app_messaging` - `v0.6.0+22`
 - `firebase_database_web` - `v0.2.1+4`
 - `firebase_database` - `v9.1.2`
 - `firebase_remote_config_web` - `v1.1.3`
 - `firebase_in_app_messaging_platform_interface` - `v0.2.1+14`
 - `firebase_remote_config` - `v2.0.15`
 - `firebase_crashlytics` - `v2.8.8`
 - `firebase_remote_config_platform_interface` - `v1.1.14`
 - `firebase_database_platform_interface` - `v0.2.2+2`
 - `firebase_dynamic_links` - `v4.3.5`
 - `firebase_dynamic_links_platform_interface` - `v0.2.3+10`
 - `cloud_firestore_web` - `v2.8.5`
 - `firebase_app_installations_web` - `v0.1.1+3`
 - `firebase_app_installations` - `v0.1.1+5`
 - `cloud_firestore` - `v3.4.5`
 - `firebase_app_installations_platform_interface` - `v0.1.1+14`
 - `cloud_firestore_platform_interface` - `v5.7.2`
 - `firebase_messaging_web` - `v3.1.2`
 - `firebase_messaging` - `v12.0.3`
 - `firebase_messaging_platform_interface` - `v4.1.2`
 - `firebase_analytics_platform_interface` - `v3.3.2`
 - `firebase_analytics` - `v9.3.2`
 - `firebase_analytics_web` - `v0.4.2+2`
 - `cloud_functions_web` - `v4.3.3`
 - `firebase_app_check` - `v0.0.6+20`
 - `cloud_functions` - `v3.3.5`
 - `cloud_functions_platform_interface` - `v5.1.14`
 - `firebase_ml_model_downloader` - `v0.1.1+5`
 - `firebase_app_check_platform_interface` - `v0.0.4+14`
 - `firebase_storage_web` - `v3.3.4`
 - `firebase_ml_model_downloader_platform_interface` - `v0.1.1+14`
 - `firebase_storage_platform_interface` - `v4.1.14`
 - `firebase_storage` - `v10.3.6`
 - `firebase_app_check_web` - `v0.0.6+3`
 - `firebase_performance` - `v0.8.2+3`
 - `firebase_performance_platform_interface` - `v0.1.1+14`
 - `firebase_performance_web` - `v0.1.1+3`
 - `cloud_firestore_odm` - `v1.0.0-dev.27`

---

#### `cloud_firestore_odm_generator` - `v1.0.0-dev.27`

 - **FIX**: replace deprecated elements from analyzer ([#9366](https://github.com/firebase/flutterfire/issues/9366)). ([89c4c429](https://github.com/firebase/flutterfire/commit/89c4c4294dc6fb376caf74704abf738ec664f85f))

#### `firebase_auth` - `v3.6.4`

 - **FIX**: fix an error where MultifactorInfo factorId could be null on iOS ([#9367](https://github.com/firebase/flutterfire/issues/9367)). ([88bded11](https://github.com/firebase/flutterfire/commit/88bded119607473c7546154ac8bdd149a2d3f21f))

#### `firebase_auth_platform_interface` - `v6.5.4`

 - **FIX**: fix an error where MultifactorInfo factorId could be null on iOS ([#9367](https://github.com/firebase/flutterfire/issues/9367)). ([88bded11](https://github.com/firebase/flutterfire/commit/88bded119607473c7546154ac8bdd149a2d3f21f))

#### `firebase_core` - `v1.21.0`

 - **FEAT**: Bump Firebase iOS SDK to 9.4.0 ([#9357](https://github.com/firebase/flutterfire/issues/9357)). ([4f356ff4](https://github.com/firebase/flutterfire/commit/4f356ff4fd5ec939c373265dd173d1cb73de1678))
 - **FEAT**: Bump Firebase android SDK to 30.3.2 ([#9358](https://github.com/firebase/flutterfire/issues/9358)). ([d6934398](https://github.com/firebase/flutterfire/commit/d69343988006cf809c61f4c31e41bd5aa8075cf5))


## 2022-08-11

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`cloud_firestore` - `v3.4.4`](#cloud_firestore---v344)
 - [`firebase_auth` - `v3.6.3`](#firebase_auth---v363)
 - [`firebase_auth_platform_interface` - `v6.5.3`](#firebase_auth_platform_interface---v653)
 - [`firebase_core` - `v1.20.1`](#firebase_core---v1201)
 - [`firebase_messaging` - `v12.0.2`](#firebase_messaging---v1202)
 - [`flutterfire_ui` - `v0.4.3+5`](#flutterfire_ui---v0435)
 - [`cloud_firestore_odm` - `v1.0.0-dev.26`](#cloud_firestore_odm---v100-dev26)
 - [`cloud_firestore_odm_generator` - `v1.0.0-dev.26`](#cloud_firestore_odm_generator---v100-dev26)
 - [`firebase_auth_web` - `v4.2.3`](#firebase_auth_web---v423)
 - [`firebase_in_app_messaging` - `v0.6.0+21`](#firebase_in_app_messaging---v06021)
 - [`firebase_in_app_messaging_platform_interface` - `v0.2.1+13`](#firebase_in_app_messaging_platform_interface---v02113)
 - [`firebase_crashlytics_platform_interface` - `v3.2.13`](#firebase_crashlytics_platform_interface---v3213)
 - [`firebase_crashlytics` - `v2.8.7`](#firebase_crashlytics---v287)
 - [`firebase_remote_config_platform_interface` - `v1.1.13`](#firebase_remote_config_platform_interface---v1113)
 - [`firebase_database` - `v9.1.1`](#firebase_database---v911)
 - [`firebase_remote_config` - `v2.0.14`](#firebase_remote_config---v2014)
 - [`firebase_remote_config_web` - `v1.1.2`](#firebase_remote_config_web---v112)
 - [`firebase_database_platform_interface` - `v0.2.2+1`](#firebase_database_platform_interface---v0221)
 - [`cloud_firestore_web` - `v2.8.4`](#cloud_firestore_web---v284)
 - [`firebase_dynamic_links_platform_interface` - `v0.2.3+9`](#firebase_dynamic_links_platform_interface---v0239)
 - [`firebase_database_web` - `v0.2.1+3`](#firebase_database_web---v0213)
 - [`firebase_dynamic_links` - `v4.3.4`](#firebase_dynamic_links---v434)
 - [`firebase_app_installations` - `v0.1.1+4`](#firebase_app_installations---v0114)
 - [`cloud_firestore_platform_interface` - `v5.7.1`](#cloud_firestore_platform_interface---v571)
 - [`firebase_messaging_web` - `v3.1.1`](#firebase_messaging_web---v311)
 - [`firebase_messaging_platform_interface` - `v4.1.1`](#firebase_messaging_platform_interface---v411)
 - [`firebase_app_installations_web` - `v0.1.1+2`](#firebase_app_installations_web---v0112)
 - [`firebase_app_installations_platform_interface` - `v0.1.1+13`](#firebase_app_installations_platform_interface---v01113)
 - [`firebase_analytics_web` - `v0.4.2+1`](#firebase_analytics_web---v0421)
 - [`firebase_analytics` - `v9.3.1`](#firebase_analytics---v931)
 - [`firebase_ml_model_downloader` - `v0.1.1+4`](#firebase_ml_model_downloader---v0114)
 - [`firebase_analytics_platform_interface` - `v3.3.1`](#firebase_analytics_platform_interface---v331)
 - [`firebase_app_check_platform_interface` - `v0.0.4+13`](#firebase_app_check_platform_interface---v00413)
 - [`firebase_ml_model_downloader_platform_interface` - `v0.1.1+13`](#firebase_ml_model_downloader_platform_interface---v01113)
 - [`firebase_app_check` - `v0.0.6+19`](#firebase_app_check---v00619)
 - [`firebase_app_check_web` - `v0.0.6+2`](#firebase_app_check_web---v0062)
 - [`cloud_functions_web` - `v4.3.2`](#cloud_functions_web---v432)
 - [`firebase_storage_web` - `v3.3.3`](#firebase_storage_web---v333)
 - [`cloud_functions` - `v3.3.4`](#cloud_functions---v334)
 - [`firebase_storage` - `v10.3.5`](#firebase_storage---v1035)
 - [`firebase_storage_platform_interface` - `v4.1.13`](#firebase_storage_platform_interface---v4113)
 - [`cloud_functions_platform_interface` - `v5.1.13`](#cloud_functions_platform_interface---v5113)
 - [`firebase_performance` - `v0.8.2+2`](#firebase_performance---v0822)
 - [`firebase_performance_platform_interface` - `v0.1.1+13`](#firebase_performance_platform_interface---v01113)
 - [`firebase_performance_web` - `v0.1.1+2`](#firebase_performance_web---v0112)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flutterfire_ui` - `v0.4.3+5`
 - `cloud_firestore_odm` - `v1.0.0-dev.26`
 - `cloud_firestore_odm_generator` - `v1.0.0-dev.26`
 - `firebase_auth_web` - `v4.2.3`
 - `firebase_in_app_messaging` - `v0.6.0+21`
 - `firebase_in_app_messaging_platform_interface` - `v0.2.1+13`
 - `firebase_crashlytics_platform_interface` - `v3.2.13`
 - `firebase_crashlytics` - `v2.8.7`
 - `firebase_remote_config_platform_interface` - `v1.1.13`
 - `firebase_database` - `v9.1.1`
 - `firebase_remote_config` - `v2.0.14`
 - `firebase_remote_config_web` - `v1.1.2`
 - `firebase_database_platform_interface` - `v0.2.2+1`
 - `cloud_firestore_web` - `v2.8.4`
 - `firebase_dynamic_links_platform_interface` - `v0.2.3+9`
 - `firebase_database_web` - `v0.2.1+3`
 - `firebase_dynamic_links` - `v4.3.4`
 - `firebase_app_installations` - `v0.1.1+4`
 - `cloud_firestore_platform_interface` - `v5.7.1`
 - `firebase_messaging_web` - `v3.1.1`
 - `firebase_messaging_platform_interface` - `v4.1.1`
 - `firebase_app_installations_web` - `v0.1.1+2`
 - `firebase_app_installations_platform_interface` - `v0.1.1+13`
 - `firebase_analytics_web` - `v0.4.2+1`
 - `firebase_analytics` - `v9.3.1`
 - `firebase_ml_model_downloader` - `v0.1.1+4`
 - `firebase_analytics_platform_interface` - `v3.3.1`
 - `firebase_app_check_platform_interface` - `v0.0.4+13`
 - `firebase_ml_model_downloader_platform_interface` - `v0.1.1+13`
 - `firebase_app_check` - `v0.0.6+19`
 - `firebase_app_check_web` - `v0.0.6+2`
 - `cloud_functions_web` - `v4.3.2`
 - `firebase_storage_web` - `v3.3.3`
 - `cloud_functions` - `v3.3.4`
 - `firebase_storage` - `v10.3.5`
 - `firebase_storage_platform_interface` - `v4.1.13`
 - `cloud_functions_platform_interface` - `v5.1.13`
 - `firebase_performance` - `v0.8.2+2`
 - `firebase_performance_platform_interface` - `v0.1.1+13`
 - `firebase_performance_web` - `v0.1.1+2`

---

#### `cloud_firestore` - `v3.4.4`

 - **FIX**: stop `FirebaseError` appearing in console on hot restart & hot refresh ([#9321](https://github.com/firebase/flutterfire/issues/9321)). ([4ba0ff9d](https://github.com/firebase/flutterfire/commit/4ba0ff9d9c7d13f7e040d80375d6db3edb8d37d5))

#### `firebase_auth` - `v3.6.3`

 - **FIX**: use correct UTC time from server for `currentUser?.metadata.creationTime` & `currentUser?.metadata.lastSignInTime` ([#9248](https://github.com/firebase/flutterfire/issues/9248)). ([a6204128](https://github.com/firebase/flutterfire/commit/a6204128edf1f54ac734385d0ed6214d50cebd1b))
 - **DOCS**: explicit mention that `refreshToken` is empty string on native platforms on the `User`instance ([#9183](https://github.com/firebase/flutterfire/issues/9183)). ([1aa1c163](https://github.com/firebase/flutterfire/commit/1aa1c1638edc632dedf8de0f02127e26b1a86e17))

#### `firebase_auth_platform_interface` - `v6.5.3`

 - **FIX**: use correct UTC time from server for `currentUser?.metadata.creationTime` & `currentUser?.metadata.lastSignInTime` ([#9248](https://github.com/firebase/flutterfire/issues/9248)). ([a6204128](https://github.com/firebase/flutterfire/commit/a6204128edf1f54ac734385d0ed6214d50cebd1b))
 - **DOCS**: explicit mention that `refreshToken` is empty string on native platforms on the `User`instance ([#9183](https://github.com/firebase/flutterfire/issues/9183)). ([1aa1c163](https://github.com/firebase/flutterfire/commit/1aa1c1638edc632dedf8de0f02127e26b1a86e17))
 - **DOCS**: add note that `persistence` is only available on web based platforms. ([#9274](https://github.com/firebase/flutterfire/issues/9274)). ([3ad2485c](https://github.com/firebase/flutterfire/commit/3ad2485ccdcce2eb9634bd7f005479a03b3265ef))

#### `firebase_core` - `v1.20.1`

 - **FIX**: broken homepage link in pubspec.yaml ([#9314](https://github.com/firebase/flutterfire/issues/9314)). ([7649c27f](https://github.com/firebase/flutterfire/commit/7649c27fde639aec8c70a1acfd86c938eeb77537))

#### `firebase_messaging` - `v12.0.2`

 - **FIX**: ensure initial notification was tapped to open app. fixes `getInitialMessage()` & `onMessageOpenedApp()` . ([#9315](https://github.com/firebase/flutterfire/issues/9315)). ([e66c59ca](https://github.com/firebase/flutterfire/commit/e66c59ca4b8a13fc4ce597cb63612eaaaefaf673))


## 2022-08-01

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`cloud_firestore_web` - `v2.8.3`](#cloud_firestore_web---v283)
 - [`firebase_auth` - `v3.6.2`](#firebase_auth---v362)
 - [`firebase_auth_platform_interface` - `v6.5.2`](#firebase_auth_platform_interface---v652)
 - [`firebase_database` - `v9.1.0`](#firebase_database---v910)
 - [`firebase_database_platform_interface` - `v0.2.2`](#firebase_database_platform_interface---v022)
 - [`firebase_database_web` - `v0.2.1+2`](#firebase_database_web---v0212)
 - [`cloud_firestore` - `v3.4.3`](#cloud_firestore---v343)
 - [`flutterfire_ui` - `v0.4.3+4`](#flutterfire_ui---v0434)
 - [`cloud_firestore_odm` - `v1.0.0-dev.25`](#cloud_firestore_odm---v100-dev25)
 - [`cloud_firestore_odm_generator` - `v1.0.0-dev.25`](#cloud_firestore_odm_generator---v100-dev25)
 - [`firebase_auth_web` - `v4.2.2`](#firebase_auth_web---v422)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `cloud_firestore` - `v3.4.3`
 - `flutterfire_ui` - `v0.4.3+4`
 - `cloud_firestore_odm` - `v1.0.0-dev.25`
 - `cloud_firestore_odm_generator` - `v1.0.0-dev.25`
 - `firebase_auth_web` - `v4.2.2`

---

#### `cloud_firestore_web` - `v2.8.3`

 - **FIX**: fix apply method for arrayRemove & arrayUnion ([#9281](https://github.com/firebase/flutterfire/issues/9281)). ([29ef7c2a](https://github.com/firebase/flutterfire/commit/29ef7c2aa4f6f9f87802806508c1b9f142a3890e))

#### `firebase_auth` - `v3.6.2`

 - **DOCS**: update `getIdTokenResult` inline documentation ([#9150](https://github.com/firebase/flutterfire/issues/9150)). ([519518ce](https://github.com/firebase/flutterfire/commit/519518ce3ed36580e35713e791281b251018201c))

#### `firebase_auth_platform_interface` - `v6.5.2`

 - **DOCS**: update `getIdTokenResult` inline documentation ([#9150](https://github.com/firebase/flutterfire/issues/9150)). ([519518ce](https://github.com/firebase/flutterfire/commit/519518ce3ed36580e35713e791281b251018201c))

#### `firebase_database` - `v9.1.0`

 - **FEAT**: `ServerValue.increment()` now correctly accepts a `num`  to support both integers and doubles. ([#9101](https://github.com/firebase/flutterfire/issues/9101)). ([35cce5b0](https://github.com/firebase/flutterfire/commit/35cce5b03fae00b1753fc9b6ed688c7f020a5007))

#### `firebase_database_platform_interface` - `v0.2.2`

 - **FEAT**: `ServerValue.increment()` now correctly accepts a `num`  to support both integers and doubles. ([#9101](https://github.com/firebase/flutterfire/issues/9101)). ([35cce5b0](https://github.com/firebase/flutterfire/commit/35cce5b03fae00b1753fc9b6ed688c7f020a5007))

#### `firebase_database_web` - `v0.2.1+2`

 - **FIX**: change the interop to fix an issue with startAt/endAt/limitTo when compilating with dart2js in release mode ([#9251](https://github.com/firebase/flutterfire/issues/9251)). ([c2771a42](https://github.com/firebase/flutterfire/commit/c2771a425bd7260b11970e9e9e77ef40a39f9f16))


## 2022-07-28

### Changes

---

Packages with breaking changes:

 - [`cloud_firestore_odm` - `v1.0.0-dev.24`](#cloud_firestore_odm---v100-dev24)
 - [`cloud_firestore_odm_generator` - `v1.0.0-dev.24`](#cloud_firestore_odm_generator---v100-dev24)

Packages with other changes:

 - [`cloud_firestore_web` - `v2.8.2`](#cloud_firestore_web---v282)
 - [`firebase_auth_platform_interface` - `v6.5.1`](#firebase_auth_platform_interface---v651)
 - [`firebase_auth_web` - `v4.2.1`](#firebase_auth_web---v421)
 - [`cloud_firestore` - `v3.4.2`](#cloud_firestore---v342)
 - [`flutterfire_ui` - `v0.4.3+3`](#flutterfire_ui---v0433)
 - [`firebase_auth` - `v3.6.1`](#firebase_auth---v361)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `cloud_firestore` - `v3.4.2`
 - `flutterfire_ui` - `v0.4.3+3`
 - `firebase_auth` - `v3.6.1`

---

#### `cloud_firestore_odm` - `v1.0.0-dev.24`

 - **FIX**: Correctly type `firestoreJsonConverters` as `List<JsonConverter>` instead of `List<Object>` ([#9236](https://github.com/firebase/flutterfire/issues/9236)). ([b39d87c7](https://github.com/firebase/flutterfire/commit/b39d87c7d62cc8bbaddc0b151ec987ee54706870))
 - **FEAT**: Add where(arrayContains) support ([#9167](https://github.com/firebase/flutterfire/issues/9167)). ([1a2f2262](https://github.com/firebase/flutterfire/commit/1a2f2262578c6230560761630d017637b99cbd6c))
 - **BREAKING** **FEAT**: The low-level interface of Queries/Document ([#9184](https://github.com/firebase/flutterfire/issues/9184)). ([fad4b0cd](https://github.com/firebase/flutterfire/commit/fad4b0cd0aa09e9161c64deeecf222c14603cd69))

#### `cloud_firestore_odm_generator` - `v1.0.0-dev.24`

 - **FEAT**: Add where(arrayContains) support ([#9167](https://github.com/firebase/flutterfire/issues/9167)). ([1a2f2262](https://github.com/firebase/flutterfire/commit/1a2f2262578c6230560761630d017637b99cbd6c))
 - **BREAKING** **FEAT**: The low-level interface of Queries/Document ([#9184](https://github.com/firebase/flutterfire/issues/9184)). ([fad4b0cd](https://github.com/firebase/flutterfire/commit/fad4b0cd0aa09e9161c64deeecf222c14603cd69))

#### `cloud_firestore_web` - `v2.8.2`

 - **FIX**: change the interop to fix an issue with startAt/endAt when compilating with dart2js in release mode ([#9246](https://github.com/firebase/flutterfire/issues/9246)). ([b4e92ed8](https://github.com/firebase/flutterfire/commit/b4e92ed854dc1e93cee42dc5ef748be7aeae7650))

#### `firebase_auth_platform_interface` - `v6.5.1`

 - **FIX**: restore default persistence to IndexedDB that was incorrectly set to localStorage ([#9247](https://github.com/firebase/flutterfire/issues/9247)). ([785c4869](https://github.com/firebase/flutterfire/commit/785c4869a45be039d3f1b1473380a1d08609c28e))

#### `firebase_auth_web` - `v4.2.1`

 - **FIX**: restore default persistence to IndexedDB that was incorrectly set to localStorage ([#9247](https://github.com/firebase/flutterfire/issues/9247)). ([785c4869](https://github.com/firebase/flutterfire/commit/785c4869a45be039d3f1b1473380a1d08609c28e))


## 2022-07-27

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`firebase_auth` - `v3.6.0`](#firebase_auth---v360)
 - [`firebase_auth_platform_interface` - `v6.5.0`](#firebase_auth_platform_interface---v650)
 - [`firebase_auth_web` - `v4.2.0`](#firebase_auth_web---v420)
 - [`firebase_storage_web` - `v3.3.2`](#firebase_storage_web---v332)
 - [`flutterfire_ui` - `v0.4.3+2`](#flutterfire_ui---v0432)
 - [`firebase_storage` - `v10.3.4`](#firebase_storage---v1034)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flutterfire_ui` - `v0.4.3+2`
 - `firebase_storage` - `v10.3.4`

---

#### `firebase_auth` - `v3.6.0`

 - **FIX**: pass `Persistence` value to `FirebaseAuth.instanceFor(app: app, persistence: persistence)` for setting persistence on Web platform ([#9138](https://github.com/firebase/flutterfire/issues/9138)). ([ae7ebaf8](https://github.com/firebase/flutterfire/commit/ae7ebaf8e304a2676b2acfa68aadf0538468b4a0))
 - **FIX**: fix crash on Android where detaching from engine was not properly resetting the Pigeon handler ([#9218](https://github.com/firebase/flutterfire/issues/9218)). ([96d35df0](https://github.com/firebase/flutterfire/commit/96d35df09914fbe40515fdcd20b17a802f37270d))
 - **FEAT**: expose the missing MultiFactor classes through the universal package ([#9194](https://github.com/firebase/flutterfire/issues/9194)). ([d8bf8185](https://github.com/firebase/flutterfire/commit/d8bf818528c3705350cdb1b4675d600ba1d29d14))

#### `firebase_auth_platform_interface` - `v6.5.0`

 - **FIX**: pass `Persistence` value to `FirebaseAuth.instanceFor(app: app, persistence: persistence)` for setting persistence on Web platform ([#9138](https://github.com/firebase/flutterfire/issues/9138)). ([ae7ebaf8](https://github.com/firebase/flutterfire/commit/ae7ebaf8e304a2676b2acfa68aadf0538468b4a0))
 - **FEAT**: expose the missing MultiFactor classes through the universal package ([#9194](https://github.com/firebase/flutterfire/issues/9194)). ([d8bf8185](https://github.com/firebase/flutterfire/commit/d8bf818528c3705350cdb1b4675d600ba1d29d14))

#### `firebase_auth_web` - `v4.2.0`

 - **FIX**: pass `Persistence` value to `FirebaseAuth.instanceFor(app: app, persistence: persistence)` for setting persistence on Web platform ([#9138](https://github.com/firebase/flutterfire/issues/9138)). ([ae7ebaf8](https://github.com/firebase/flutterfire/commit/ae7ebaf8e304a2676b2acfa68aadf0538468b4a0))
 - **FEAT**: expose the missing MultiFactor classes through the universal package ([#9194](https://github.com/firebase/flutterfire/issues/9194)). ([d8bf8185](https://github.com/firebase/flutterfire/commit/d8bf818528c3705350cdb1b4675d600ba1d29d14))

#### `firebase_storage_web` - `v3.3.2`

 - **FIX**: fix UploadTask by fixing TaskEvent Web Interop ([#9212](https://github.com/firebase/flutterfire/issues/9212)). ([6df75ca0](https://github.com/firebase/flutterfire/commit/6df75ca09b0ae1334d2f80804c1386f8baac13fa))


## 2022-07-25

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`cloud_firestore_web` - `v2.8.1`](#cloud_firestore_web---v281)
 - [`firebase_analytics` - `v9.3.0`](#firebase_analytics---v930)
 - [`firebase_analytics_platform_interface` - `v3.3.0`](#firebase_analytics_platform_interface---v330)
 - [`firebase_analytics_web` - `v0.4.2`](#firebase_analytics_web---v042)
 - [`firebase_auth_web` - `v4.1.1`](#firebase_auth_web---v411)
 - [`cloud_firestore` - `v3.4.1`](#cloud_firestore---v341)
 - [`flutterfire_ui` - `v0.4.3+1`](#flutterfire_ui---v0431)
 - [`cloud_firestore_odm` - `v1.0.0-dev.23`](#cloud_firestore_odm---v100-dev23)
 - [`cloud_firestore_odm_generator` - `v1.0.0-dev.23`](#cloud_firestore_odm_generator---v100-dev23)
 - [`firebase_auth` - `v3.5.1`](#firebase_auth---v351)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `cloud_firestore` - `v3.4.1`
 - `flutterfire_ui` - `v0.4.3+1`
 - `cloud_firestore_odm` - `v1.0.0-dev.23`
 - `cloud_firestore_odm_generator` - `v1.0.0-dev.23`
 - `firebase_auth` - `v3.5.1`

---

#### `cloud_firestore_web` - `v2.8.1`

 - **FIX**: fix interop on TransactionOptions ([#9188](https://github.com/firebase/flutterfire/issues/9188)). ([f0201674](https://github.com/firebase/flutterfire/commit/f0201674a3dfe1a6ce103f2aa6ad2b994dcc1da8))

#### `firebase_analytics` - `v9.3.0`

 - **FEAT**: retrieves `appInstanceId` property on native platforms if available ([#8689](https://github.com/firebase/flutterfire/issues/8689)). ([7132d771](https://github.com/firebase/flutterfire/commit/7132d771ed5ada7a0433232b9f0d996ef0d61481))

#### `firebase_analytics_platform_interface` - `v3.3.0`

 - **FEAT**: retrieves `appInstanceId` property on native platforms if available ([#8689](https://github.com/firebase/flutterfire/issues/8689)). ([7132d771](https://github.com/firebase/flutterfire/commit/7132d771ed5ada7a0433232b9f0d996ef0d61481))

#### `firebase_analytics_web` - `v0.4.2`

 - **FEAT**: retrieves `appInstanceId` property on native platforms if available ([#8689](https://github.com/firebase/flutterfire/issues/8689)). ([7132d771](https://github.com/firebase/flutterfire/commit/7132d771ed5ada7a0433232b9f0d996ef0d61481))

#### `firebase_auth_web` - `v4.1.1`

 - **FIX**: provide `browserPopupRedirectResolver` on init ([#9146](https://github.com/firebase/flutterfire/issues/9146)). ([bf1d9be1](https://github.com/firebase/flutterfire/commit/bf1d9be11a59475be173b01184efb53d92d152fe))


## 2022-07-21

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`cloud_firestore` - `v3.4.0`](#cloud_firestore---v340)
 - [`cloud_firestore_platform_interface` - `v5.7.0`](#cloud_firestore_platform_interface---v570)
 - [`cloud_firestore_web` - `v2.8.0`](#cloud_firestore_web---v280)
 - [`firebase_analytics` - `v9.2.1`](#firebase_analytics---v921)
 - [`firebase_analytics_platform_interface` - `v3.2.1`](#firebase_analytics_platform_interface---v321)
 - [`firebase_analytics_web` - `v0.4.1+1`](#firebase_analytics_web---v0411)
 - [`firebase_auth` - `v3.5.0`](#firebase_auth---v350)
 - [`firebase_auth_platform_interface` - `v6.4.0`](#firebase_auth_platform_interface---v640)
 - [`firebase_auth_web` - `v4.1.0`](#firebase_auth_web---v410)
 - [`firebase_core` - `v1.20.0`](#firebase_core---v1200)
 - [`firebase_core_platform_interface` - `v4.5.0`](#firebase_core_platform_interface---v450)
 - [`firebase_messaging_platform_interface` - `v4.1.0`](#firebase_messaging_platform_interface---v410)
 - [`firebase_messaging_web` - `v3.1.0`](#firebase_messaging_web---v310)
 - [`flutterfire_ui` - `v0.4.3`](#flutterfire_ui---v043)
 - [`cloud_firestore_odm` - `v1.0.0-dev.22`](#cloud_firestore_odm---v100-dev22)
 - [`cloud_firestore_odm_generator` - `v1.0.0-dev.22`](#cloud_firestore_odm_generator---v100-dev22)
 - [`firebase_in_app_messaging` - `v0.6.0+20`](#firebase_in_app_messaging---v06020)
 - [`firebase_in_app_messaging_platform_interface` - `v0.2.1+12`](#firebase_in_app_messaging_platform_interface---v02112)
 - [`firebase_crashlytics` - `v2.8.6`](#firebase_crashlytics---v286)
 - [`firebase_crashlytics_platform_interface` - `v3.2.12`](#firebase_crashlytics_platform_interface---v3212)
 - [`firebase_remote_config` - `v2.0.13`](#firebase_remote_config---v2013)
 - [`firebase_database_web` - `v0.2.1+1`](#firebase_database_web---v0211)
 - [`firebase_remote_config_platform_interface` - `v1.1.12`](#firebase_remote_config_platform_interface---v1112)
 - [`firebase_database_platform_interface` - `v0.2.1+12`](#firebase_database_platform_interface---v02112)
 - [`firebase_database` - `v9.0.20`](#firebase_database---v9020)
 - [`firebase_remote_config_web` - `v1.1.1`](#firebase_remote_config_web---v111)
 - [`firebase_app_installations_web` - `v0.1.1+1`](#firebase_app_installations_web---v0111)
 - [`firebase_dynamic_links` - `v4.3.3`](#firebase_dynamic_links---v433)
 - [`firebase_dynamic_links_platform_interface` - `v0.2.3+8`](#firebase_dynamic_links_platform_interface---v0238)
 - [`firebase_app_installations_platform_interface` - `v0.1.1+12`](#firebase_app_installations_platform_interface---v01112)
 - [`firebase_app_installations` - `v0.1.1+3`](#firebase_app_installations---v0113)
 - [`firebase_messaging` - `v12.0.1`](#firebase_messaging---v1201)
 - [`firebase_ml_model_downloader` - `v0.1.1+3`](#firebase_ml_model_downloader---v0113)
 - [`firebase_ml_model_downloader_platform_interface` - `v0.1.1+12`](#firebase_ml_model_downloader_platform_interface---v01112)
 - [`firebase_app_check_platform_interface` - `v0.0.4+12`](#firebase_app_check_platform_interface---v00412)
 - [`firebase_app_check` - `v0.0.6+18`](#firebase_app_check---v00618)
 - [`firebase_app_check_web` - `v0.0.6+1`](#firebase_app_check_web---v0061)
 - [`cloud_functions_web` - `v4.3.1`](#cloud_functions_web---v431)
 - [`cloud_functions` - `v3.3.3`](#cloud_functions---v333)
 - [`firebase_storage_platform_interface` - `v4.1.12`](#firebase_storage_platform_interface---v4112)
 - [`firebase_storage_web` - `v3.3.1`](#firebase_storage_web---v331)
 - [`cloud_functions_platform_interface` - `v5.1.12`](#cloud_functions_platform_interface---v5112)
 - [`firebase_performance_platform_interface` - `v0.1.1+12`](#firebase_performance_platform_interface---v01112)
 - [`firebase_performance` - `v0.8.2+1`](#firebase_performance---v0821)
 - [`firebase_storage` - `v10.3.3`](#firebase_storage---v1033)
 - [`firebase_performance_web` - `v0.1.1+1`](#firebase_performance_web---v0111)
 - [`firebase_core_web` - `v1.7.1`](#firebase_core_web---v171)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `cloud_firestore_odm` - `v1.0.0-dev.22`
 - `cloud_firestore_odm_generator` - `v1.0.0-dev.22`
 - `firebase_in_app_messaging` - `v0.6.0+20`
 - `firebase_in_app_messaging_platform_interface` - `v0.2.1+12`
 - `firebase_crashlytics` - `v2.8.6`
 - `firebase_crashlytics_platform_interface` - `v3.2.12`
 - `firebase_remote_config` - `v2.0.13`
 - `firebase_database_web` - `v0.2.1+1`
 - `firebase_remote_config_platform_interface` - `v1.1.12`
 - `firebase_database_platform_interface` - `v0.2.1+12`
 - `firebase_database` - `v9.0.20`
 - `firebase_remote_config_web` - `v1.1.1`
 - `firebase_app_installations_web` - `v0.1.1+1`
 - `firebase_dynamic_links` - `v4.3.3`
 - `firebase_dynamic_links_platform_interface` - `v0.2.3+8`
 - `firebase_app_installations_platform_interface` - `v0.1.1+12`
 - `firebase_app_installations` - `v0.1.1+3`
 - `firebase_messaging` - `v12.0.1`
 - `firebase_ml_model_downloader` - `v0.1.1+3`
 - `firebase_ml_model_downloader_platform_interface` - `v0.1.1+12`
 - `firebase_app_check_platform_interface` - `v0.0.4+12`
 - `firebase_app_check` - `v0.0.6+18`
 - `firebase_app_check_web` - `v0.0.6+1`
 - `cloud_functions_web` - `v4.3.1`
 - `cloud_functions` - `v3.3.3`
 - `firebase_storage_platform_interface` - `v4.1.12`
 - `firebase_storage_web` - `v3.3.1`
 - `cloud_functions_platform_interface` - `v5.1.12`
 - `firebase_performance_platform_interface` - `v0.1.1+12`
 - `firebase_performance` - `v0.8.2+1`
 - `firebase_storage` - `v10.3.3`
 - `firebase_performance_web` - `v0.1.1+1`
 - `firebase_core_web` - `v1.7.1`

---

#### `cloud_firestore` - `v3.4.0`

 - **FEAT**: add max attempts for Firestore transactions ([#9163](https://github.com/firebase/flutterfire/issues/9163)). ([9da7cc36](https://github.com/firebase/flutterfire/commit/9da7cc36cb266e4f5a0de26dfe727e0a4687f1a0))
 - **FEAT**: update to 9.3.0 ([#9137](https://github.com/firebase/flutterfire/issues/9137)). ([97f6417b](https://github.com/firebase/flutterfire/commit/97f6417bf66f88e6621afa177c73245b9a7d5c73))

#### `cloud_firestore_platform_interface` - `v5.7.0`

 - **FEAT**: add max attempts for Firestore transactions ([#9163](https://github.com/firebase/flutterfire/issues/9163)). ([9da7cc36](https://github.com/firebase/flutterfire/commit/9da7cc36cb266e4f5a0de26dfe727e0a4687f1a0))

#### `cloud_firestore_web` - `v2.8.0`

 - **FEAT**: add max attempts for Firestore transactions ([#9163](https://github.com/firebase/flutterfire/issues/9163)). ([9da7cc36](https://github.com/firebase/flutterfire/commit/9da7cc36cb266e4f5a0de26dfe727e0a4687f1a0))

#### `firebase_analytics` - `v9.2.1`

 - **FIX**: allow `null` values for `setDefaultEventParameters()` which removes defaults. Permissible on android and iOS. ([#9135](https://github.com/firebase/flutterfire/issues/9135)). ([dff46a3f](https://github.com/firebase/flutterfire/commit/dff46a3f33d0b9881864f79be659b2770526677d))

#### `firebase_analytics_platform_interface` - `v3.2.1`

 - **FIX**: allow `null` values for `setDefaultEventParameters()` which removes defaults. Permissible on android and iOS. ([#9135](https://github.com/firebase/flutterfire/issues/9135)). ([dff46a3f](https://github.com/firebase/flutterfire/commit/dff46a3f33d0b9881864f79be659b2770526677d))

#### `firebase_analytics_web` - `v0.4.1+1`

 - **FIX**: allow `null` values for `setDefaultEventParameters()` which removes defaults. Permissible on android and iOS. ([#9135](https://github.com/firebase/flutterfire/issues/9135)). ([dff46a3f](https://github.com/firebase/flutterfire/commit/dff46a3f33d0b9881864f79be659b2770526677d))

#### `firebase_auth` - `v3.5.0`

 - **FEAT**: add all providers available to MFA ([#9159](https://github.com/firebase/flutterfire/issues/9159)). ([5a03a859](https://github.com/firebase/flutterfire/commit/5a03a859385f0b06ad9afe8e8c706c046976b8d8))
 - **FEAT**: add phone MFA ([#9044](https://github.com/firebase/flutterfire/issues/9044)). ([1b85c8b7](https://github.com/firebase/flutterfire/commit/1b85c8b7fbcc3f21767f23981cb35061772d483f))

#### `firebase_auth_platform_interface` - `v6.4.0`

 - **FEAT**: add phone MFA ([#9044](https://github.com/firebase/flutterfire/issues/9044)). ([1b85c8b7](https://github.com/firebase/flutterfire/commit/1b85c8b7fbcc3f21767f23981cb35061772d483f))

#### `firebase_auth_web` - `v4.1.0`

 - **FEAT**: add all providers available to MFA ([#9159](https://github.com/firebase/flutterfire/issues/9159)). ([5a03a859](https://github.com/firebase/flutterfire/commit/5a03a859385f0b06ad9afe8e8c706c046976b8d8))
 - **FEAT**: add phone MFA ([#9044](https://github.com/firebase/flutterfire/issues/9044)). ([1b85c8b7](https://github.com/firebase/flutterfire/commit/1b85c8b7fbcc3f21767f23981cb35061772d483f))

#### `firebase_core` - `v1.20.0`

 - **FEAT**: bump Firebase Android SDK to 30.3.0 ([#9161](https://github.com/firebase/flutterfire/issues/9161)). ([d1f96310](https://github.com/firebase/flutterfire/commit/d1f96310310c7584c4af751e1e75dc178aacce89))
 - **FEAT**: add phone MFA ([#9044](https://github.com/firebase/flutterfire/issues/9044)). ([1b85c8b7](https://github.com/firebase/flutterfire/commit/1b85c8b7fbcc3f21767f23981cb35061772d483f))
 - **FEAT**: update to 9.3.0 ([#9137](https://github.com/firebase/flutterfire/issues/9137)). ([97f6417b](https://github.com/firebase/flutterfire/commit/97f6417bf66f88e6621afa177c73245b9a7d5c73))

#### `firebase_core_platform_interface` - `v4.5.0`

 - **FEAT**: add phone MFA ([#9044](https://github.com/firebase/flutterfire/issues/9044)). ([1b85c8b7](https://github.com/firebase/flutterfire/commit/1b85c8b7fbcc3f21767f23981cb35061772d483f))

#### `firebase_messaging_platform_interface` - `v4.1.0`

 - **FEAT**: Added 'criticalAlert' to notification settings. ([#9004](https://github.com/firebase/flutterfire/issues/9004)). ([4c425f27](https://github.com/firebase/flutterfire/commit/4c425f27595a6784e80d98ee0879c3fe6a5fe907))

#### `firebase_messaging_web` - `v3.1.0`

 - **FEAT**: Added 'criticalAlert' to notification settings. ([#9004](https://github.com/firebase/flutterfire/issues/9004)). ([4c425f27](https://github.com/firebase/flutterfire/commit/4c425f27595a6784e80d98ee0879c3fe6a5fe907))

#### `flutterfire_ui` - `v0.4.3`

 - **FEAT**: add max attempts for Firestore transactions ([#9163](https://github.com/firebase/flutterfire/issues/9163)). ([9da7cc36](https://github.com/firebase/flutterfire/commit/9da7cc36cb266e4f5a0de26dfe727e0a4687f1a0))
 - **FEAT**: add phone MFA ([#9044](https://github.com/firebase/flutterfire/issues/9044)). ([1b85c8b7](https://github.com/firebase/flutterfire/commit/1b85c8b7fbcc3f21767f23981cb35061772d483f))


## 2022-07-12

### Changes

---

Packages with breaking changes:

 - [`firebase_auth_web` - `v4.0.0`](#firebase_auth_web---v400)
 - [`firebase_messaging` - `v12.0.0`](#firebase_messaging---v1200)
 - [`firebase_messaging_platform_interface` - `v4.0.0`](#firebase_messaging_platform_interface---v400)
 - [`firebase_messaging_web` - `v3.0.0`](#firebase_messaging_web---v300)

Packages with other changes:

 - [`cloud_firestore` - `v3.3.0`](#cloud_firestore---v330)
 - [`cloud_firestore_odm` - `v1.0.0-dev.21`](#cloud_firestore_odm---v100-dev21)
 - [`cloud_firestore_odm_generator` - `v1.0.0-dev.21`](#cloud_firestore_odm_generator---v100-dev21)
 - [`cloud_firestore_platform_interface` - `v5.6.0`](#cloud_firestore_platform_interface---v560)
 - [`cloud_firestore_web` - `v2.7.0`](#cloud_firestore_web---v270)
 - [`cloud_functions_web` - `v4.3.0`](#cloud_functions_web---v430)
 - [`firebase_analytics` - `v9.2.0`](#firebase_analytics---v920)
 - [`firebase_analytics_platform_interface` - `v3.2.0`](#firebase_analytics_platform_interface---v320)
 - [`firebase_analytics_web` - `v0.4.1`](#firebase_analytics_web---v041)
 - [`firebase_app_check_web` - `v0.0.6`](#firebase_app_check_web---v006)
 - [`firebase_app_installations_web` - `v0.1.1`](#firebase_app_installations_web---v011)
 - [`firebase_core_web` - `v1.7.0`](#firebase_core_web---v170)
 - [`firebase_crashlytics` - `v2.8.5`](#firebase_crashlytics---v285)
 - [`firebase_database_web` - `v0.2.1`](#firebase_database_web---v021)
 - [`firebase_performance` - `v0.8.2`](#firebase_performance---v082)
 - [`firebase_performance_web` - `v0.1.1`](#firebase_performance_web---v011)
 - [`firebase_remote_config_web` - `v1.1.0`](#firebase_remote_config_web---v110)
 - [`firebase_storage_web` - `v3.3.0`](#firebase_storage_web---v330)
 - [`flutterfire_ui` - `v0.4.2+3`](#flutterfire_ui---v0423)
 - [`cloud_functions` - `v3.3.2`](#cloud_functions---v332)
 - [`firebase_app_check` - `v0.0.6+17`](#firebase_app_check---v00617)
 - [`firebase_app_installations` - `v0.1.1+2`](#firebase_app_installations---v0112)
 - [`firebase_auth` - `v3.4.2`](#firebase_auth---v342)
 - [`firebase_core` - `v1.19.2`](#firebase_core---v1192)
 - [`firebase_remote_config` - `v2.0.12`](#firebase_remote_config---v2012)
 - [`firebase_database` - `v9.0.19`](#firebase_database---v9019)
 - [`firebase_auth_platform_interface` - `v6.3.2`](#firebase_auth_platform_interface---v632)
 - [`firebase_remote_config_platform_interface` - `v1.1.11`](#firebase_remote_config_platform_interface---v1111)
 - [`firebase_in_app_messaging` - `v0.6.0+19`](#firebase_in_app_messaging---v06019)
 - [`firebase_in_app_messaging_platform_interface` - `v0.2.1+11`](#firebase_in_app_messaging_platform_interface---v02111)
 - [`firebase_dynamic_links` - `v4.3.2`](#firebase_dynamic_links---v432)
 - [`firebase_database_platform_interface` - `v0.2.1+11`](#firebase_database_platform_interface---v02111)
 - [`firebase_crashlytics_platform_interface` - `v3.2.11`](#firebase_crashlytics_platform_interface---v3211)
 - [`firebase_app_installations_platform_interface` - `v0.1.1+11`](#firebase_app_installations_platform_interface---v01111)
 - [`firebase_dynamic_links_platform_interface` - `v0.2.3+7`](#firebase_dynamic_links_platform_interface---v0237)
 - [`firebase_ml_model_downloader_platform_interface` - `v0.1.1+11`](#firebase_ml_model_downloader_platform_interface---v01111)
 - [`firebase_app_check_platform_interface` - `v0.0.4+11`](#firebase_app_check_platform_interface---v00411)
 - [`cloud_functions_platform_interface` - `v5.1.11`](#cloud_functions_platform_interface---v5111)
 - [`firebase_storage_platform_interface` - `v4.1.11`](#firebase_storage_platform_interface---v4111)
 - [`firebase_ml_model_downloader` - `v0.1.1+2`](#firebase_ml_model_downloader---v0112)
 - [`firebase_performance_platform_interface` - `v0.1.1+11`](#firebase_performance_platform_interface---v01111)
 - [`firebase_storage` - `v10.3.2`](#firebase_storage---v1032)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flutterfire_ui` - `v0.4.2+3`
 - `cloud_functions` - `v3.3.2`
 - `firebase_app_check` - `v0.0.6+17`
 - `firebase_app_installations` - `v0.1.1+2`
 - `firebase_auth` - `v3.4.2`
 - `firebase_core` - `v1.19.2`
 - `firebase_remote_config` - `v2.0.12`
 - `firebase_database` - `v9.0.19`
 - `firebase_auth_platform_interface` - `v6.3.2`
 - `firebase_remote_config_platform_interface` - `v1.1.11`
 - `firebase_in_app_messaging` - `v0.6.0+19`
 - `firebase_in_app_messaging_platform_interface` - `v0.2.1+11`
 - `firebase_dynamic_links` - `v4.3.2`
 - `firebase_database_platform_interface` - `v0.2.1+11`
 - `firebase_crashlytics_platform_interface` - `v3.2.11`
 - `firebase_app_installations_platform_interface` - `v0.1.1+11`
 - `firebase_dynamic_links_platform_interface` - `v0.2.3+7`
 - `firebase_ml_model_downloader_platform_interface` - `v0.1.1+11`
 - `firebase_app_check_platform_interface` - `v0.0.4+11`
 - `cloud_functions_platform_interface` - `v5.1.11`
 - `firebase_storage_platform_interface` - `v4.1.11`
 - `firebase_ml_model_downloader` - `v0.1.1+2`
 - `firebase_performance_platform_interface` - `v0.1.1+11`
 - `firebase_storage` - `v10.3.2`

---

#### `firebase_auth_web` - `v4.0.0`

 - **BREAKING** **FEAT**: upgrade auth web to Firebase v9 JS SDK ([#8236](https://github.com/firebase/flutterfire/issues/8236)). ([8e95a51d](https://github.com/firebase/flutterfire/commit/8e95a51d99ffc5fec106d933e46c9f331c1e2d50))
 - **BREAKING**: Cannot set `updateDisplayName()` or `updatePhotoURL()` to `null` on web anymore.

#### `firebase_messaging` - `v12.0.0`

 - **DOCS**: fix usage link to the documentation in the README.md ([#9027](https://github.com/firebase/flutterfire/issues/9027)). ([037e3a5f](https://github.com/firebase/flutterfire/commit/037e3a5f3d41a3914ed8e6fa394e42c44fe29186))
 - **BREAKING** **FEAT**: upgrade messaging web to Firebase v9 JS SDK. ([#8860](https://github.com/firebase/flutterfire/issues/8860)). ([f3a6bdc5](https://github.com/firebase/flutterfire/commit/f3a6bdc5fd2441ed3c77a9d0ece0d6460afd2ec4))
 - **BREAKING**: `isSupported()` API is now asynchronous and returns `Future<bool>`. It is web only and will always resolve to `true` on other platforms.

#### `firebase_messaging_platform_interface` - `v4.0.0`

 - **BREAKING** **FEAT**: upgrade messaging web to Firebase v9 JS SDK. ([#8860](https://github.com/firebase/flutterfire/issues/8860)). ([f3a6bdc5](https://github.com/firebase/flutterfire/commit/f3a6bdc5fd2441ed3c77a9d0ece0d6460afd2ec4))
 - **BREAKING**: `isSupported()` API is now asynchronous and returns `Future<bool>`. It is web only and will always resolve to `true` on other platforms.

#### `firebase_messaging_web` - `v3.0.0`

 - **BREAKING** **FEAT**: upgrade messaging web to Firebase v9 JS SDK. ([#8860](https://github.com/firebase/flutterfire/issues/8860)). ([f3a6bdc5](https://github.com/firebase/flutterfire/commit/f3a6bdc5fd2441ed3c77a9d0ece0d6460afd2ec4))
 - **BREAKING**: `isSupported()` API is now asynchronous and returns `Future<bool>`. It is web only and will always resolve to `true` on other platforms.

#### `cloud_firestore` - `v3.3.0`

 - **FEAT**: upgrade to support v9.8.1 Firebase JS SDK ([#8235](https://github.com/firebase/flutterfire/issues/8235)). ([4b417af5](https://github.com/firebase/flutterfire/commit/4b417af574bb8a32ca8e4b3ab2ff253a22be9903))

#### `cloud_firestore_odm` - `v1.0.0-dev.21`

 - **FEAT**: add orderByFieldPath / whereFieldPath ([#8951](https://github.com/firebase/flutterfire/issues/8951)). ([5957c23b](https://github.com/firebase/flutterfire/commit/5957c23b44b235dab9d97449acb9c737da07b8e7))
 - **FEAT**: Add support for DateTime/Timestamp/GeoPoint ([#8563](https://github.com/firebase/flutterfire/issues/8563)). ([f2ea3696](https://github.com/firebase/flutterfire/commit/f2ea36964662d396dbc26bd931bb2662a5898168))
 - **FEAT**: add support for json_serializable's field rename/property ignore ([#9030](https://github.com/firebase/flutterfire/issues/9030)). ([81ec08fd](https://github.com/firebase/flutterfire/commit/81ec08fd64d57b4fbdc8e4fca39b5ab84dcc8669))

#### `cloud_firestore_odm_generator` - `v1.0.0-dev.21`

 - **FEAT**: add orderByFieldPath / whereFieldPath ([#8951](https://github.com/firebase/flutterfire/issues/8951)). ([5957c23b](https://github.com/firebase/flutterfire/commit/5957c23b44b235dab9d97449acb9c737da07b8e7))
 - **FEAT**: Add support for DateTime/Timestamp/GeoPoint ([#8563](https://github.com/firebase/flutterfire/issues/8563)). ([f2ea3696](https://github.com/firebase/flutterfire/commit/f2ea36964662d396dbc26bd931bb2662a5898168))
 - **FEAT**: add support for json_serializable's field rename/property ignore ([#9030](https://github.com/firebase/flutterfire/issues/9030)). ([81ec08fd](https://github.com/firebase/flutterfire/commit/81ec08fd64d57b4fbdc8e4fca39b5ab84dcc8669))

#### `cloud_firestore_platform_interface` - `v5.6.0`

 - **FEAT**: upgrade to support v9.8.1 Firebase JS SDK ([#8235](https://github.com/firebase/flutterfire/issues/8235)). ([4b417af5](https://github.com/firebase/flutterfire/commit/4b417af574bb8a32ca8e4b3ab2ff253a22be9903))

#### `cloud_firestore_web` - `v2.7.0`

 - **FEAT**: upgrade to support v9.8.1 Firebase JS SDK ([#8235](https://github.com/firebase/flutterfire/issues/8235)). ([4b417af5](https://github.com/firebase/flutterfire/commit/4b417af574bb8a32ca8e4b3ab2ff253a22be9903))

#### `cloud_functions_web` - `v4.3.0`

 - **FEAT**: upgrade to support v9.8.1 Firebase JS SDK ([#8235](https://github.com/firebase/flutterfire/issues/8235)). ([4b417af5](https://github.com/firebase/flutterfire/commit/4b417af574bb8a32ca8e4b3ab2ff253a22be9903))

#### `firebase_analytics` - `v9.2.0`

 - **FEAT**: upgrade to support v9.8.1 Firebase JS SDK ([#8235](https://github.com/firebase/flutterfire/issues/8235)). ([4b417af5](https://github.com/firebase/flutterfire/commit/4b417af574bb8a32ca8e4b3ab2ff253a22be9903))

#### `firebase_analytics_platform_interface` - `v3.2.0`

 - **FEAT**: upgrade to support v9.8.1 Firebase JS SDK ([#8235](https://github.com/firebase/flutterfire/issues/8235)). ([4b417af5](https://github.com/firebase/flutterfire/commit/4b417af574bb8a32ca8e4b3ab2ff253a22be9903))

#### `firebase_analytics_web` - `v0.4.1`

 - **FEAT**: upgrade to support v9.8.1 Firebase JS SDK ([#8235](https://github.com/firebase/flutterfire/issues/8235)). ([4b417af5](https://github.com/firebase/flutterfire/commit/4b417af574bb8a32ca8e4b3ab2ff253a22be9903))

#### `firebase_app_check_web` - `v0.0.6`

 - **FEAT**: upgrade to support v9.8.1 Firebase JS SDK ([#8235](https://github.com/firebase/flutterfire/issues/8235)). ([4b417af5](https://github.com/firebase/flutterfire/commit/4b417af574bb8a32ca8e4b3ab2ff253a22be9903))

#### `firebase_app_installations_web` - `v0.1.1`

 - **FEAT**: upgrade to support v9.8.1 Firebase JS SDK ([#8235](https://github.com/firebase/flutterfire/issues/8235)). ([4b417af5](https://github.com/firebase/flutterfire/commit/4b417af574bb8a32ca8e4b3ab2ff253a22be9903))

#### `firebase_core_web` - `v1.7.0`

 - **FEAT**: web JS v9.9.0 SDK bump ([#9075](https://github.com/firebase/flutterfire/issues/9075)). ([200a7747](https://github.com/firebase/flutterfire/commit/200a7747945155a99694d245c9b53ee3526a1da9))
 - **FEAT**: upgrade to support v9.8.1 Firebase JS SDK ([#8235](https://github.com/firebase/flutterfire/issues/8235)). ([4b417af5](https://github.com/firebase/flutterfire/commit/4b417af574bb8a32ca8e4b3ab2ff253a22be9903))

#### `firebase_crashlytics` - `v2.8.5`

 - **FIX**: `[core/duplicate-app]` exception when running the example ([#8991](https://github.com/firebase/flutterfire/issues/8991)). ([c70e66a5](https://github.com/firebase/flutterfire/commit/c70e66a546cf9236e728796c5b59a3d4e39caeb2))

#### `firebase_database_web` - `v0.2.1`

 - **FEAT**: upgrade to support v9.8.1 Firebase JS SDK ([#8235](https://github.com/firebase/flutterfire/issues/8235)). ([4b417af5](https://github.com/firebase/flutterfire/commit/4b417af574bb8a32ca8e4b3ab2ff253a22be9903))

#### `firebase_performance` - `v0.8.2`

 - **FEAT**: upgrade to support v9.8.1 Firebase JS SDK ([#8235](https://github.com/firebase/flutterfire/issues/8235)). ([4b417af5](https://github.com/firebase/flutterfire/commit/4b417af574bb8a32ca8e4b3ab2ff253a22be9903))

#### `firebase_performance_web` - `v0.1.1`

 - **FEAT**: upgrade to support v9.8.1 Firebase JS SDK ([#8235](https://github.com/firebase/flutterfire/issues/8235)). ([4b417af5](https://github.com/firebase/flutterfire/commit/4b417af574bb8a32ca8e4b3ab2ff253a22be9903))

#### `firebase_remote_config_web` - `v1.1.0`

 - **FEAT**: upgrade to support v9.8.1 Firebase JS SDK ([#8235](https://github.com/firebase/flutterfire/issues/8235)). ([4b417af5](https://github.com/firebase/flutterfire/commit/4b417af574bb8a32ca8e4b3ab2ff253a22be9903))

#### `firebase_storage_web` - `v3.3.0`

 - **FEAT**: upgrade to support v9.8.1 Firebase JS SDK ([#8235](https://github.com/firebase/flutterfire/issues/8235)). ([4b417af5](https://github.com/firebase/flutterfire/commit/4b417af574bb8a32ca8e4b3ab2ff253a22be9903))


## 2022-07-01

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`cloud_firestore` - `v3.2.1`](#cloud_firestore---v321)
 - [`cloud_firestore_platform_interface` - `v5.5.10`](#cloud_firestore_platform_interface---v5510)
 - [`cloud_firestore_web` - `v2.6.19`](#cloud_firestore_web---v2619)
 - [`cloud_functions` - `v3.3.1`](#cloud_functions---v331)
 - [`cloud_functions_platform_interface` - `v5.1.10`](#cloud_functions_platform_interface---v5110)
 - [`cloud_functions_web` - `v4.2.18`](#cloud_functions_web---v4218)
 - [`firebase_analytics` - `v9.1.12`](#firebase_analytics---v9112)
 - [`firebase_analytics_platform_interface` - `v3.1.10`](#firebase_analytics_platform_interface---v3110)
 - [`firebase_app_check` - `v0.0.6+16`](#firebase_app_check---v00616)
 - [`firebase_app_check_platform_interface` - `v0.0.4+10`](#firebase_app_check_platform_interface---v00410)
 - [`firebase_app_check_web` - `v0.0.5+16`](#firebase_app_check_web---v00516)
 - [`firebase_app_installations` - `v0.1.1+1`](#firebase_app_installations---v0111)
 - [`firebase_app_installations_platform_interface` - `v0.1.1+10`](#firebase_app_installations_platform_interface---v01110)
 - [`firebase_app_installations_web` - `v0.1.0+17`](#firebase_app_installations_web---v01017)
 - [`firebase_auth` - `v3.4.1`](#firebase_auth---v341)
 - [`firebase_auth_platform_interface` - `v6.3.1`](#firebase_auth_platform_interface---v631)
 - [`firebase_auth_web` - `v3.3.19`](#firebase_auth_web---v3319)
 - [`firebase_core` - `v1.19.1`](#firebase_core---v1191)
 - [`firebase_core_platform_interface` - `v4.4.3`](#firebase_core_platform_interface---v443)
 - [`firebase_core_web` - `v1.6.6`](#firebase_core_web---v166)
 - [`firebase_crashlytics` - `v2.8.4`](#firebase_crashlytics---v284)
 - [`firebase_crashlytics_platform_interface` - `v3.2.10`](#firebase_crashlytics_platform_interface---v3210)
 - [`firebase_database` - `v9.0.18`](#firebase_database---v9018)
 - [`firebase_database_platform_interface` - `v0.2.1+10`](#firebase_database_platform_interface---v02110)
 - [`firebase_database_web` - `v0.2.0+17`](#firebase_database_web---v02017)
 - [`firebase_dynamic_links` - `v4.3.1`](#firebase_dynamic_links---v431)
 - [`firebase_dynamic_links_platform_interface` - `v0.2.3+6`](#firebase_dynamic_links_platform_interface---v0236)
 - [`firebase_in_app_messaging` - `v0.6.0+18`](#firebase_in_app_messaging---v06018)
 - [`firebase_in_app_messaging_platform_interface` - `v0.2.1+10`](#firebase_in_app_messaging_platform_interface---v02110)
 - [`firebase_messaging` - `v11.4.4`](#firebase_messaging---v1144)
 - [`firebase_messaging_platform_interface` - `v3.5.4`](#firebase_messaging_platform_interface---v354)
 - [`firebase_messaging_web` - `v2.4.4`](#firebase_messaging_web---v244)
 - [`firebase_ml_model_downloader` - `v0.1.1+1`](#firebase_ml_model_downloader---v0111)
 - [`firebase_ml_model_downloader_platform_interface` - `v0.1.1+10`](#firebase_ml_model_downloader_platform_interface---v01110)
 - [`firebase_performance` - `v0.8.1+1`](#firebase_performance---v0811)
 - [`firebase_performance_platform_interface` - `v0.1.1+10`](#firebase_performance_platform_interface---v01110)
 - [`firebase_remote_config` - `v2.0.11`](#firebase_remote_config---v2011)
 - [`firebase_remote_config_platform_interface` - `v1.1.10`](#firebase_remote_config_platform_interface---v1110)
 - [`firebase_remote_config_web` - `v1.0.16`](#firebase_remote_config_web---v1016)
 - [`firebase_storage` - `v10.3.1`](#firebase_storage---v1031)
 - [`firebase_storage_platform_interface` - `v4.1.10`](#firebase_storage_platform_interface---v4110)
 - [`firebase_storage_web` - `v3.2.19`](#firebase_storage_web---v3219)
 - [`cloud_firestore_odm` - `v1.0.0-dev.20`](#cloud_firestore_odm---v100-dev20)
 - [`flutterfire_ui` - `v0.4.2+2`](#flutterfire_ui---v0422)
 - [`cloud_firestore_odm_generator` - `v1.0.0-dev.20`](#cloud_firestore_odm_generator---v100-dev20)
 - [`firebase_analytics_web` - `v0.4.0+17`](#firebase_analytics_web---v04017)
 - [`firebase_performance_web` - `v0.1.0+16`](#firebase_performance_web---v01016)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `cloud_firestore_odm` - `v1.0.0-dev.20`
 - `flutterfire_ui` - `v0.4.2+2`
 - `cloud_firestore_odm_generator` - `v1.0.0-dev.20`
 - `firebase_analytics_web` - `v0.4.0+17`
 - `firebase_performance_web` - `v0.1.0+16`

---

#### `cloud_firestore` - `v3.2.1`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `cloud_firestore_platform_interface` - `v5.5.10`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `cloud_firestore_web` - `v2.6.19`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `cloud_functions` - `v3.3.1`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `cloud_functions_platform_interface` - `v5.1.10`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `cloud_functions_web` - `v4.2.18`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_analytics` - `v9.1.12`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_analytics_platform_interface` - `v3.1.10`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_app_check` - `v0.0.6+16`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_app_check_platform_interface` - `v0.0.4+10`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_app_check_web` - `v0.0.5+16`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_app_installations` - `v0.1.1+1`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_app_installations_platform_interface` - `v0.1.1+10`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_app_installations_web` - `v0.1.0+17`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_auth` - `v3.4.1`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_auth_platform_interface` - `v6.3.1`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_auth_web` - `v3.3.19`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_core` - `v1.19.1`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_core_platform_interface` - `v4.4.3`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_core_web` - `v1.6.6`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_crashlytics` - `v2.8.4`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_crashlytics_platform_interface` - `v3.2.10`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_database` - `v9.0.18`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_database_platform_interface` - `v0.2.1+10`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_database_web` - `v0.2.0+17`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_dynamic_links` - `v4.3.1`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_dynamic_links_platform_interface` - `v0.2.3+6`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_in_app_messaging` - `v0.6.0+18`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_in_app_messaging_platform_interface` - `v0.2.1+10`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_messaging` - `v11.4.4`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_messaging_platform_interface` - `v3.5.4`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_messaging_web` - `v2.4.4`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_ml_model_downloader` - `v0.1.1+1`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_ml_model_downloader_platform_interface` - `v0.1.1+10`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_performance` - `v0.8.1+1`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_performance_platform_interface` - `v0.1.1+10`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_remote_config` - `v2.0.11`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_remote_config_platform_interface` - `v1.1.10`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_remote_config_web` - `v1.0.16`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_storage` - `v10.3.1`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_storage_platform_interface` - `v4.1.10`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))

#### `firebase_storage_web` - `v3.2.19`

 - **FIX**: bump `firebase_core_platform_interface` version to fix previous release. ([bea70ea5](https://github.com/firebase/flutterfire/commit/bea70ea5cbbb62cbfd2a7a74ae3a07cb12b3ee5a))


## 2022-07-01

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`firebase_core_platform_interface` - `v4.4.2`](#firebase_core_platform_interface---v442)
 - [`firebase_in_app_messaging` - `v0.6.0+18`](#firebase_in_app_messaging---v06018)
 - [`firebase_crashlytics` - `v2.8.4`](#firebase_crashlytics---v284)
 - [`firebase_auth` - `v3.4.1`](#firebase_auth---v341)
 - [`firebase_remote_config` - `v2.0.11`](#firebase_remote_config---v2011)
 - [`firebase_dynamic_links` - `v4.3.1`](#firebase_dynamic_links---v431)
 - [`firebase_database` - `v9.0.18`](#firebase_database---v9018)
 - [`cloud_firestore` - `v3.2.1`](#cloud_firestore---v321)
 - [`firebase_app_installations` - `v0.1.1+1`](#firebase_app_installations---v0111)
 - [`firebase_messaging` - `v11.4.4`](#firebase_messaging---v1144)
 - [`firebase_core_web` - `v1.6.6`](#firebase_core_web---v166)
 - [`firebase_core` - `v1.19.1`](#firebase_core---v1191)
 - [`firebase_analytics` - `v9.1.12`](#firebase_analytics---v9112)
 - [`firebase_app_check` - `v0.0.6+16`](#firebase_app_check---v00616)
 - [`firebase_ml_model_downloader` - `v0.1.1+1`](#firebase_ml_model_downloader---v0111)
 - [`cloud_functions` - `v3.3.1`](#cloud_functions---v331)
 - [`firebase_storage` - `v10.3.1`](#firebase_storage---v1031)
 - [`firebase_performance` - `v0.8.1+1`](#firebase_performance---v0811)
 - [`flutterfire_ui` - `v0.4.2+2`](#flutterfire_ui---v0422)
 - [`cloud_firestore_odm` - `v1.0.0-dev.20`](#cloud_firestore_odm---v100-dev20)
 - [`firebase_remote_config_web` - `v1.0.16`](#firebase_remote_config_web---v1016)
 - [`firebase_auth_web` - `v3.3.19`](#firebase_auth_web---v3319)
 - [`firebase_database_web` - `v0.2.0+17`](#firebase_database_web---v02017)
 - [`cloud_firestore_web` - `v2.6.19`](#cloud_firestore_web---v2619)
 - [`firebase_app_installations_web` - `v0.1.0+17`](#firebase_app_installations_web---v01017)
 - [`firebase_messaging_web` - `v2.4.4`](#firebase_messaging_web---v244)
 - [`firebase_analytics_web` - `v0.4.0+17`](#firebase_analytics_web---v04017)
 - [`firebase_app_check_web` - `v0.0.5+16`](#firebase_app_check_web---v00516)
 - [`cloud_functions_web` - `v4.2.18`](#cloud_functions_web---v4218)
 - [`firebase_storage_web` - `v3.2.19`](#firebase_storage_web---v3219)
 - [`firebase_performance_web` - `v0.1.0+16`](#firebase_performance_web---v01016)
 - [`firebase_in_app_messaging_platform_interface` - `v0.2.1+10`](#firebase_in_app_messaging_platform_interface---v02110)
 - [`firebase_crashlytics_platform_interface` - `v3.2.10`](#firebase_crashlytics_platform_interface---v3210)
 - [`firebase_auth_platform_interface` - `v6.3.1`](#firebase_auth_platform_interface---v631)
 - [`firebase_remote_config_platform_interface` - `v1.1.10`](#firebase_remote_config_platform_interface---v1110)
 - [`firebase_database_platform_interface` - `v0.2.1+10`](#firebase_database_platform_interface---v02110)
 - [`firebase_dynamic_links_platform_interface` - `v0.2.3+6`](#firebase_dynamic_links_platform_interface---v0236)
 - [`cloud_firestore_platform_interface` - `v5.5.10`](#cloud_firestore_platform_interface---v5510)
 - [`firebase_messaging_platform_interface` - `v3.5.4`](#firebase_messaging_platform_interface---v354)
 - [`firebase_app_installations_platform_interface` - `v0.1.1+10`](#firebase_app_installations_platform_interface---v01110)
 - [`firebase_analytics_platform_interface` - `v3.1.10`](#firebase_analytics_platform_interface---v3110)
 - [`firebase_app_check_platform_interface` - `v0.0.4+10`](#firebase_app_check_platform_interface---v00410)
 - [`firebase_ml_model_downloader_platform_interface` - `v0.1.1+10`](#firebase_ml_model_downloader_platform_interface---v01110)
 - [`cloud_functions_platform_interface` - `v5.1.10`](#cloud_functions_platform_interface---v5110)
 - [`firebase_performance_platform_interface` - `v0.1.1+10`](#firebase_performance_platform_interface---v01110)
 - [`firebase_storage_platform_interface` - `v4.1.10`](#firebase_storage_platform_interface---v4110)
 - [`cloud_firestore_odm_generator` - `v1.0.0-dev.20`](#cloud_firestore_odm_generator---v100-dev20)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `firebase_in_app_messaging` - `v0.6.0+18`
 - `firebase_crashlytics` - `v2.8.4`
 - `firebase_auth` - `v3.4.1`
 - `firebase_remote_config` - `v2.0.11`
 - `firebase_dynamic_links` - `v4.3.1`
 - `firebase_database` - `v9.0.18`
 - `cloud_firestore` - `v3.2.1`
 - `firebase_app_installations` - `v0.1.1+1`
 - `firebase_messaging` - `v11.4.4`
 - `firebase_core_web` - `v1.6.6`
 - `firebase_core` - `v1.19.1`
 - `firebase_analytics` - `v9.1.12`
 - `firebase_app_check` - `v0.0.6+16`
 - `firebase_ml_model_downloader` - `v0.1.1+1`
 - `cloud_functions` - `v3.3.1`
 - `firebase_storage` - `v10.3.1`
 - `firebase_performance` - `v0.8.1+1`
 - `flutterfire_ui` - `v0.4.2+2`
 - `cloud_firestore_odm` - `v1.0.0-dev.20`
 - `firebase_remote_config_web` - `v1.0.16`
 - `firebase_auth_web` - `v3.3.19`
 - `firebase_database_web` - `v0.2.0+17`
 - `cloud_firestore_web` - `v2.6.19`
 - `firebase_app_installations_web` - `v0.1.0+17`
 - `firebase_messaging_web` - `v2.4.4`
 - `firebase_analytics_web` - `v0.4.0+17`
 - `firebase_app_check_web` - `v0.0.5+16`
 - `cloud_functions_web` - `v4.2.18`
 - `firebase_storage_web` - `v3.2.19`
 - `firebase_performance_web` - `v0.1.0+16`
 - `firebase_in_app_messaging_platform_interface` - `v0.2.1+10`
 - `firebase_crashlytics_platform_interface` - `v3.2.10`
 - `firebase_auth_platform_interface` - `v6.3.1`
 - `firebase_remote_config_platform_interface` - `v1.1.10`
 - `firebase_database_platform_interface` - `v0.2.1+10`
 - `firebase_dynamic_links_platform_interface` - `v0.2.3+6`
 - `cloud_firestore_platform_interface` - `v5.5.10`
 - `firebase_messaging_platform_interface` - `v3.5.4`
 - `firebase_app_installations_platform_interface` - `v0.1.1+10`
 - `firebase_analytics_platform_interface` - `v3.1.10`
 - `firebase_app_check_platform_interface` - `v0.0.4+10`
 - `firebase_ml_model_downloader_platform_interface` - `v0.1.1+10`
 - `cloud_functions_platform_interface` - `v5.1.10`
 - `firebase_performance_platform_interface` - `v0.1.1+10`
 - `firebase_storage_platform_interface` - `v4.1.10`
 - `cloud_firestore_odm_generator` - `v1.0.0-dev.20`

---

#### `firebase_core_platform_interface` - `v4.4.2`

 - Manual version to fix previous release.


## 2022-06-30

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`cloud_firestore` - `v3.2.0`](#cloud_firestore---v320)
 - [`cloud_firestore_odm` - `v1.0.0-dev.19`](#cloud_firestore_odm---v100-dev19)
 - [`cloud_firestore_odm_generator` - `v1.0.0-dev.19`](#cloud_firestore_odm_generator---v100-dev19)
 - [`cloud_functions` - `v3.3.0`](#cloud_functions---v330)
 - [`firebase_app_check` - `v0.0.6+15`](#firebase_app_check---v00615)
 - [`firebase_app_installations` - `v0.1.1`](#firebase_app_installations---v011)
 - [`firebase_auth` - `v3.4.0`](#firebase_auth---v340)
 - [`firebase_auth_platform_interface` - `v6.3.0`](#firebase_auth_platform_interface---v630)
 - [`firebase_auth_web` - `v3.3.18`](#firebase_auth_web---v3318)
 - [`firebase_core` - `v1.19.0`](#firebase_core---v1190)
 - [`firebase_dynamic_links` - `v4.3.0`](#firebase_dynamic_links---v430)
 - [`firebase_ml_model_downloader` - `v0.1.1`](#firebase_ml_model_downloader---v011)
 - [`firebase_performance` - `v0.8.1`](#firebase_performance---v081)
 - [`firebase_storage` - `v10.3.0`](#firebase_storage---v1030)
 - [`flutterfire_ui` - `v0.4.2+1`](#flutterfire_ui---v0421)
 - [`firebase_in_app_messaging` - `v0.6.0+17`](#firebase_in_app_messaging---v06017)
 - [`firebase_in_app_messaging_platform_interface` - `v0.2.1+9`](#firebase_in_app_messaging_platform_interface---v0219)
 - [`firebase_crashlytics` - `v2.8.3`](#firebase_crashlytics---v283)
 - [`firebase_crashlytics_platform_interface` - `v3.2.9`](#firebase_crashlytics_platform_interface---v329)
 - [`firebase_remote_config` - `v2.0.10`](#firebase_remote_config---v2010)
 - [`firebase_remote_config_web` - `v1.0.15`](#firebase_remote_config_web---v1015)
 - [`firebase_remote_config_platform_interface` - `v1.1.9`](#firebase_remote_config_platform_interface---v119)
 - [`firebase_database_web` - `v0.2.0+16`](#firebase_database_web---v02016)
 - [`firebase_database` - `v9.0.17`](#firebase_database---v9017)
 - [`firebase_database_platform_interface` - `v0.2.1+9`](#firebase_database_platform_interface---v0219)
 - [`firebase_dynamic_links_platform_interface` - `v0.2.3+5`](#firebase_dynamic_links_platform_interface---v0235)
 - [`cloud_firestore_web` - `v2.6.18`](#cloud_firestore_web---v2618)
 - [`cloud_firestore_platform_interface` - `v5.5.9`](#cloud_firestore_platform_interface---v559)
 - [`firebase_app_installations_web` - `v0.1.0+16`](#firebase_app_installations_web---v01016)
 - [`firebase_app_installations_platform_interface` - `v0.1.1+9`](#firebase_app_installations_platform_interface---v0119)
 - [`firebase_messaging_web` - `v2.4.3`](#firebase_messaging_web---v243)
 - [`firebase_messaging` - `v11.4.3`](#firebase_messaging---v1143)
 - [`firebase_messaging_platform_interface` - `v3.5.3`](#firebase_messaging_platform_interface---v353)
 - [`firebase_analytics_platform_interface` - `v3.1.9`](#firebase_analytics_platform_interface---v319)
 - [`firebase_analytics` - `v9.1.11`](#firebase_analytics---v9111)
 - [`firebase_analytics_web` - `v0.4.0+16`](#firebase_analytics_web---v04016)
 - [`firebase_ml_model_downloader_platform_interface` - `v0.1.1+9`](#firebase_ml_model_downloader_platform_interface---v0119)
 - [`firebase_app_check_platform_interface` - `v0.0.4+9`](#firebase_app_check_platform_interface---v0049)
 - [`firebase_app_check_web` - `v0.0.5+15`](#firebase_app_check_web---v00515)
 - [`cloud_functions_web` - `v4.2.17`](#cloud_functions_web---v4217)
 - [`cloud_functions_platform_interface` - `v5.1.9`](#cloud_functions_platform_interface---v519)
 - [`firebase_storage_web` - `v3.2.18`](#firebase_storage_web---v3218)
 - [`firebase_storage_platform_interface` - `v4.1.9`](#firebase_storage_platform_interface---v419)
 - [`firebase_performance_platform_interface` - `v0.1.1+9`](#firebase_performance_platform_interface---v0119)
 - [`firebase_performance_web` - `v0.1.0+15`](#firebase_performance_web---v01015)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `firebase_in_app_messaging` - `v0.6.0+17`
 - `firebase_in_app_messaging_platform_interface` - `v0.2.1+9`
 - `firebase_crashlytics` - `v2.8.3`
 - `firebase_crashlytics_platform_interface` - `v3.2.9`
 - `firebase_remote_config` - `v2.0.10`
 - `firebase_remote_config_web` - `v1.0.15`
 - `firebase_remote_config_platform_interface` - `v1.1.9`
 - `firebase_database_web` - `v0.2.0+16`
 - `firebase_database` - `v9.0.17`
 - `firebase_database_platform_interface` - `v0.2.1+9`
 - `firebase_dynamic_links_platform_interface` - `v0.2.3+5`
 - `cloud_firestore_web` - `v2.6.18`
 - `cloud_firestore_platform_interface` - `v5.5.9`
 - `firebase_app_installations_web` - `v0.1.0+16`
 - `firebase_app_installations_platform_interface` - `v0.1.1+9`
 - `firebase_messaging_web` - `v2.4.3`
 - `firebase_messaging` - `v11.4.3`
 - `firebase_messaging_platform_interface` - `v3.5.3`
 - `firebase_analytics_platform_interface` - `v3.1.9`
 - `firebase_analytics` - `v9.1.11`
 - `firebase_analytics_web` - `v0.4.0+16`
 - `firebase_ml_model_downloader_platform_interface` - `v0.1.1+9`
 - `firebase_app_check_platform_interface` - `v0.0.4+9`
 - `firebase_app_check_web` - `v0.0.5+15`
 - `cloud_functions_web` - `v4.2.17`
 - `cloud_functions_platform_interface` - `v5.1.9`
 - `firebase_storage_web` - `v3.2.18`
 - `firebase_storage_platform_interface` - `v4.1.9`
 - `firebase_performance_platform_interface` - `v0.1.1+9`
 - `firebase_performance_web` - `v0.1.0+15`

---

#### `cloud_firestore` - `v3.2.0`

 - **FEAT**: Bump Firebase iOS SDK to `9.2.0` (#8594). ([79610162](https://github.com/firebase/flutterfire/commit/79610162460b8877f3bc727464a7065106f08079))

#### `cloud_firestore_odm` - `v1.0.0-dev.19`

 - **FEAT**: add whereDocumentId/orderByDocumentId (#8935). ([3769bcca](https://github.com/firebase/flutterfire/commit/3769bccadedc2c12228ec51dfb48561a23055370))

#### `cloud_firestore_odm_generator` - `v1.0.0-dev.19`

 - **FEAT**: add whereDocumentId/orderByDocumentId (#8935). ([3769bcca](https://github.com/firebase/flutterfire/commit/3769bccadedc2c12228ec51dfb48561a23055370))

#### `cloud_functions` - `v3.3.0`

 - **FEAT**: Bump Firebase iOS SDK to `9.2.0` (#8594). ([79610162](https://github.com/firebase/flutterfire/commit/79610162460b8877f3bc727464a7065106f08079))

#### `firebase_app_check` - `v0.0.6+15`

 - **DOCS**: separate the first sentence of a doc comment into its own paragraph for `getToken()` (#8968). ([4d487ef7](https://github.com/firebase/flutterfire/commit/4d487ef7abdb9a8333735ced9c40438fef9912a3))

#### `firebase_app_installations` - `v0.1.1`

 - **REFACTOR**: use `firebase.google.com` link for `homepage` in `pubspec.yaml` (#8728). ([05a1a75b](https://github.com/firebase/flutterfire/commit/05a1a75bce84c1c73547485fe406ec430aefdf40))
 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))
 - **FEAT**: Bump Firebase iOS SDK to `9.2.0` (#8594). ([79610162](https://github.com/firebase/flutterfire/commit/79610162460b8877f3bc727464a7065106f08079))
 - **DOCS**: point to "firebase.google" domain for hyperlinks in the usage section of `README.md` files (for the missing packages) (#8818). ([5bda8c92](https://github.com/firebase/flutterfire/commit/5bda8c92be1651a941d1285d36e885ee0b967b11))

#### `firebase_auth` - `v3.4.0`

 - **FIX**: Web recaptcha hover removed after use. (#8812). ([790e450e](https://github.com/firebase/flutterfire/commit/790e450e8d6acd2fc50e0232c77a152430c7b3ea))
 - **FIX**: java.util.ConcurrentModificationException (#8967). ([dc6c04ae](https://github.com/firebase/flutterfire/commit/dc6c04aeb4fc535a8ccadf9c11fb4d5dc413606d))
 - **FEAT**: update GitHub sign in implementation (#8976). ([ffd3b019](https://github.com/firebase/flutterfire/commit/ffd3b019c3158c66476671d9a9df245035cc2295))

#### `firebase_auth_platform_interface` - `v6.3.0`

 - **FEAT**: update GitHub sign in implementation (#8976). ([ffd3b019](https://github.com/firebase/flutterfire/commit/ffd3b019c3158c66476671d9a9df245035cc2295))

#### `firebase_auth_web` - `v3.3.18`

 - **FIX**: Web recaptcha hover removed after use. (#8812). ([790e450e](https://github.com/firebase/flutterfire/commit/790e450e8d6acd2fc50e0232c77a152430c7b3ea))

#### `firebase_core` - `v1.19.0`

 - **FEAT**: Bump Firebase iOS SDK to `9.2.0` (#8594). ([79610162](https://github.com/firebase/flutterfire/commit/79610162460b8877f3bc727464a7065106f08079))

#### `firebase_dynamic_links` - `v4.3.0`

 - **FEAT**: Bump Firebase iOS SDK to `9.2.0` (#8594). ([79610162](https://github.com/firebase/flutterfire/commit/79610162460b8877f3bc727464a7065106f08079))

#### `firebase_ml_model_downloader` - `v0.1.1`

 - **FEAT**: Bump Firebase iOS SDK to `9.2.0` (#8594). ([79610162](https://github.com/firebase/flutterfire/commit/79610162460b8877f3bc727464a7065106f08079))

#### `firebase_performance` - `v0.8.1`

 - **FEAT**: Bump Firebase iOS SDK to `9.2.0` (#8594). ([79610162](https://github.com/firebase/flutterfire/commit/79610162460b8877f3bc727464a7065106f08079))

#### `firebase_storage` - `v10.3.0`

 - **FEAT**: Bump Firebase iOS SDK to `9.2.0` (#8594). ([79610162](https://github.com/firebase/flutterfire/commit/79610162460b8877f3bc727464a7065106f08079))

#### `flutterfire_ui` - `v0.4.2+1`

 - **FIX**: migrate flutterfire_ui to flutter v3 (#8949). ([528f8eae](https://github.com/firebase/flutterfire/commit/528f8eae3d138493dfba8532ec00196e39b90c49))


## 2022-06-16

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`cloud_firestore` - `v3.1.18`](#cloud_firestore---v3118)
 - [`cloud_firestore_odm` - `v1.0.0-dev.18`](#cloud_firestore_odm---v100-dev18)
 - [`cloud_firestore_odm_generator` - `v1.0.0-dev.18`](#cloud_firestore_odm_generator---v100-dev18)
 - [`cloud_firestore_platform_interface` - `v5.5.8`](#cloud_firestore_platform_interface---v558)
 - [`cloud_firestore_web` - `v2.6.17`](#cloud_firestore_web---v2617)
 - [`cloud_functions` - `v3.2.17`](#cloud_functions---v3217)
 - [`cloud_functions_platform_interface` - `v5.1.8`](#cloud_functions_platform_interface---v518)
 - [`cloud_functions_web` - `v4.2.16`](#cloud_functions_web---v4216)
 - [`firebase_analytics` - `v9.1.10`](#firebase_analytics---v9110)
 - [`firebase_analytics_platform_interface` - `v3.1.8`](#firebase_analytics_platform_interface---v318)
 - [`firebase_analytics_web` - `v0.4.0+15`](#firebase_analytics_web---v04015)
 - [`firebase_app_check` - `v0.0.6+14`](#firebase_app_check---v00614)
 - [`firebase_app_check_platform_interface` - `v0.0.4+8`](#firebase_app_check_platform_interface---v0048)
 - [`firebase_app_check_web` - `v0.0.5+14`](#firebase_app_check_web---v00514)
 - [`firebase_app_installations` - `v0.1.0+14`](#firebase_app_installations---v01014)
 - [`firebase_app_installations_platform_interface` - `v0.1.1+8`](#firebase_app_installations_platform_interface---v0118)
 - [`firebase_app_installations_web` - `v0.1.0+15`](#firebase_app_installations_web---v01015)
 - [`firebase_auth` - `v3.3.20`](#firebase_auth---v3320)
 - [`firebase_auth_platform_interface` - `v6.2.8`](#firebase_auth_platform_interface---v628)
 - [`firebase_auth_web` - `v3.3.17`](#firebase_auth_web---v3317)
 - [`firebase_core` - `v1.18.0`](#firebase_core---v1180)
 - [`firebase_core_platform_interface` - `v4.4.1`](#firebase_core_platform_interface---v441)
 - [`firebase_core_web` - `v1.6.5`](#firebase_core_web---v165)
 - [`firebase_crashlytics` - `v2.8.2`](#firebase_crashlytics---v282)
 - [`firebase_crashlytics_platform_interface` - `v3.2.8`](#firebase_crashlytics_platform_interface---v328)
 - [`firebase_database` - `v9.0.16`](#firebase_database---v9016)
 - [`firebase_database_platform_interface` - `v0.2.1+8`](#firebase_database_platform_interface---v0218)
 - [`firebase_database_web` - `v0.2.0+15`](#firebase_database_web---v02015)
 - [`firebase_dynamic_links` - `v4.2.6`](#firebase_dynamic_links---v426)
 - [`firebase_dynamic_links_platform_interface` - `v0.2.3+4`](#firebase_dynamic_links_platform_interface---v0234)
 - [`firebase_in_app_messaging` - `v0.6.0+16`](#firebase_in_app_messaging---v06016)
 - [`firebase_in_app_messaging_platform_interface` - `v0.2.1+8`](#firebase_in_app_messaging_platform_interface---v0218)
 - [`firebase_messaging` - `v11.4.2`](#firebase_messaging---v1142)
 - [`firebase_messaging_platform_interface` - `v3.5.2`](#firebase_messaging_platform_interface---v352)
 - [`firebase_messaging_web` - `v2.4.2`](#firebase_messaging_web---v242)
 - [`firebase_ml_model_downloader` - `v0.1.0+15`](#firebase_ml_model_downloader---v01015)
 - [`firebase_ml_model_downloader_platform_interface` - `v0.1.1+8`](#firebase_ml_model_downloader_platform_interface---v0118)
 - [`firebase_performance` - `v0.8.0+14`](#firebase_performance---v08014)
 - [`firebase_performance_platform_interface` - `v0.1.1+8`](#firebase_performance_platform_interface---v0118)
 - [`firebase_performance_web` - `v0.1.0+14`](#firebase_performance_web---v01014)
 - [`firebase_remote_config` - `v2.0.9`](#firebase_remote_config---v209)
 - [`firebase_remote_config_platform_interface` - `v1.1.8`](#firebase_remote_config_platform_interface---v118)
 - [`firebase_remote_config_web` - `v1.0.14`](#firebase_remote_config_web---v1014)
 - [`firebase_storage` - `v10.2.18`](#firebase_storage---v10218)
 - [`firebase_storage_platform_interface` - `v4.1.8`](#firebase_storage_platform_interface---v418)
 - [`firebase_storage_web` - `v3.2.17`](#firebase_storage_web---v3217)
 - [`flutterfire_ui` - `v0.4.2`](#flutterfire_ui---v042)

---

#### `cloud_firestore` - `v3.1.18`

 - **REFACTOR**: use `firebase.google.com` link for `homepage` in `pubspec.yaml` (#8724). ([fd3f3102](https://github.com/firebase/flutterfire/commit/fd3f3102a0614e0e155756239a57b54fab324c2c))
 - **REFACTOR**: migrate from hash* to Object.hash* (#8797). ([3dfc0997](https://github.com/firebase/flutterfire/commit/3dfc0997050ee4351207c355b2c22b46885f971f))
 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

#### `cloud_firestore_odm` - `v1.0.0-dev.18`

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

#### `cloud_firestore_odm_generator` - `v1.0.0-dev.18`

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

#### `cloud_firestore_platform_interface` - `v5.5.8`

 - **REFACTOR**: migrate from hash* to Object.hash* (#8797). ([3dfc0997](https://github.com/firebase/flutterfire/commit/3dfc0997050ee4351207c355b2c22b46885f971f))
 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

#### `cloud_firestore_web` - `v2.6.17`

 - **REFACTOR**: migrate from hash* to Object.hash* (#8797). ([3dfc0997](https://github.com/firebase/flutterfire/commit/3dfc0997050ee4351207c355b2c22b46885f971f))
 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

#### `cloud_functions` - `v3.2.17`

 - **REFACTOR**: use `firebase.google.com` link for `homepage` in `pubspec.yaml` (#8725). ([520f59d4](https://github.com/firebase/flutterfire/commit/520f59d4f2a998a646edf20cad6df1c614e5b4c3))
 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))
 - **DOCS**: point to "firebase.google" domain for hyperlinks in the usage section of `README.md` files (for the missing packages) (#8818). ([5bda8c92](https://github.com/firebase/flutterfire/commit/5bda8c92be1651a941d1285d36e885ee0b967b11))

#### `cloud_functions_platform_interface` - `v5.1.8`

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

#### `cloud_functions_web` - `v4.2.16`

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

#### `firebase_analytics` - `v9.1.10`

 - **REFACTOR**: remove deprecated `Tasks.call` for android and replace with `TaskCompletionSource`. (#8583). ([94310ab3](https://github.com/firebase/flutterfire/commit/94310ab338ad1bf34174b19d1d5db8a856e8d161))
 - **REFACTOR**: use `firebase.google.com` link for `homepage` in `pubspec.yaml` (#8726). ([ab2cdfcd](https://github.com/firebase/flutterfire/commit/ab2cdfcd291a1045add1ba196b758e1d46571934))
 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))
 - **DOCS**: point to "firebase.google" domain for hyperlinks in the usage section of `README.md` files (for the missing packages) (#8818). ([5bda8c92](https://github.com/firebase/flutterfire/commit/5bda8c92be1651a941d1285d36e885ee0b967b11))

#### `firebase_analytics_platform_interface` - `v3.1.8`

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

#### `firebase_analytics_web` - `v0.4.0+15`

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

#### `firebase_app_check` - `v0.0.6+14`

 - **REFACTOR**: use `firebase.google.com` link for `homepage` in `pubspec.yaml` (#8727). ([41a963b3](https://github.com/firebase/flutterfire/commit/41a963b376ae4ec23e1394bc074f8feee6ae16b2))
 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))
 - **DOCS**: point to "firebase.google" domain for hyperlinks in the usage section of `README.md` files (for the missing packages) (#8818). ([5bda8c92](https://github.com/firebase/flutterfire/commit/5bda8c92be1651a941d1285d36e885ee0b967b11))

#### `firebase_app_check_platform_interface` - `v0.0.4+8`

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

#### `firebase_app_check_web` - `v0.0.5+14`

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

#### `firebase_app_installations` - `v0.1.0+14`

 - **REFACTOR**: use `firebase.google.com` link for `homepage` in `pubspec.yaml` (#8728). ([05a1a75b](https://github.com/firebase/flutterfire/commit/05a1a75bce84c1c73547485fe406ec430aefdf40))
 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))
 - **DOCS**: point to "firebase.google" domain for hyperlinks in the usage section of `README.md` files (for the missing packages) (#8818). ([5bda8c92](https://github.com/firebase/flutterfire/commit/5bda8c92be1651a941d1285d36e885ee0b967b11))

#### `firebase_app_installations_platform_interface` - `v0.1.1+8`

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

#### `firebase_app_installations_web` - `v0.1.0+15`

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

#### `firebase_auth` - `v3.3.20`

 - **REFACTOR**: use `firebase.google.com` link for `homepage` in `pubspec.yaml` (#8729). ([43df32d4](https://github.com/firebase/flutterfire/commit/43df32d457a28523f5956a2252dafd47856ac756))
 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))
 - **FIX**: update firebase_auth example to not be dependent on an emulator (#8601). ([bdc9772e](https://github.com/firebase/flutterfire/commit/bdc9772ec8a3fb6609b66c42166d6d132ddb67d9))
 - **DOCS**: fix two typos. (#8876). ([7390d5c5](https://github.com/firebase/flutterfire/commit/7390d5c51e61aeb4d59c0d74093921fad3f35083))
 - **DOCS**: point to "firebase.google" domain for hyperlinks in the usage section of `README.md` files (#8814). ([78006e0d](https://github.com/firebase/flutterfire/commit/78006e0d5b9dce8038ce3606a43ddcbc8a4a71b9))

#### `firebase_auth_platform_interface` - `v6.2.8`

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

#### `firebase_auth_web` - `v3.3.17`

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

#### `firebase_core` - `v1.18.0`

 - **REFACTOR**: migrate from hash* to Object.hash* (#8797). ([3dfc0997](https://github.com/firebase/flutterfire/commit/3dfc0997050ee4351207c355b2c22b46885f971f))
 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))
 - **FEAT**: bump Firebase Android SDK to 30.1.0 (#8847). ([796f1e74](https://github.com/firebase/flutterfire/commit/796f1e744fa361a023aba4ec7f491387a9e2f0f8))
 - **DOCS**: point to "firebase.google" domain for hyperlinks in the usage section of `README.md` files (for the missing packages) (#8818). ([5bda8c92](https://github.com/firebase/flutterfire/commit/5bda8c92be1651a941d1285d36e885ee0b967b11))

#### `firebase_core_platform_interface` - `v4.4.1`

 - **REFACTOR**: migrate from hash* to Object.hash* (#8797). ([3dfc0997](https://github.com/firebase/flutterfire/commit/3dfc0997050ee4351207c355b2c22b46885f971f))
 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

#### `firebase_core_web` - `v1.6.5`

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

#### `firebase_crashlytics` - `v2.8.2`

 - **REFACTOR**: use `firebase.google.com` link for `homepage` in `pubspec.yaml` (#8731). ([c534eb04](https://github.com/firebase/flutterfire/commit/c534eb045a2ced454fdc803d438c3cd0f0b8097a))
 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))
 - **FIX**: fix deprecation warning in Android (#8903). ([f2e03484](https://github.com/firebase/flutterfire/commit/f2e03484f99bd2efcb065d31721b9a2b6e801bf5))
 - **DOCS**: point to "firebase.google" domain for hyperlinks in the usage section of `README.md` files (for the missing packages) (#8818). ([5bda8c92](https://github.com/firebase/flutterfire/commit/5bda8c92be1651a941d1285d36e885ee0b967b11))

#### `firebase_crashlytics_platform_interface` - `v3.2.8`

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

#### `firebase_database` - `v9.0.16`

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))
 - **DOCS**: point to "firebase.google" domain for hyperlinks in the usage section of `README.md` files (#8814). ([78006e0d](https://github.com/firebase/flutterfire/commit/78006e0d5b9dce8038ce3606a43ddcbc8a4a71b9))

#### `firebase_database_platform_interface` - `v0.2.1+8`

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

#### `firebase_database_web` - `v0.2.0+15`

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

#### `firebase_dynamic_links` - `v4.2.6`

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))
 - **DOCS**: point to "firebase.google" domain for hyperlinks in the usage section of `README.md` files (for the missing packages) (#8818). ([5bda8c92](https://github.com/firebase/flutterfire/commit/5bda8c92be1651a941d1285d36e885ee0b967b11))

#### `firebase_dynamic_links_platform_interface` - `v0.2.3+4`

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

#### `firebase_in_app_messaging` - `v0.6.0+16`

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))
 - **DOCS**: point to "firebase.google" domain for hyperlinks in the usage section of `README.md` files (for the missing packages) (#8818). ([5bda8c92](https://github.com/firebase/flutterfire/commit/5bda8c92be1651a941d1285d36e885ee0b967b11))

#### `firebase_in_app_messaging_platform_interface` - `v0.2.1+8`

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

#### `firebase_messaging` - `v11.4.2`

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))
 - **FIX**: Swizzle check for FlutterAppLifeCycleProvider instead of UNUserNotificationCenterDelegate (#8822). ([81f6b274](https://github.com/firebase/flutterfire/commit/81f6b2743b99e47c16fc3ee13cc1e7e6e7982730))
 - **DOCS**: clarify when `vapidKey` parameter is needed when calling `getToken()` (#8905). ([5ded8652](https://github.com/firebase/flutterfire/commit/5ded86528fad07f9eac9d70e4a49db372350f50d))
 - **DOCS**: fix typo "RemoteMesage" in `messaging.dart` (#8906). ([fd016cd0](https://github.com/firebase/flutterfire/commit/fd016cd09221adde82836a777c770d604d4f99b6))
 - **DOCS**: point to "firebase.google" domain for hyperlinks in the usage section of `README.md` files (#8814). ([78006e0d](https://github.com/firebase/flutterfire/commit/78006e0d5b9dce8038ce3606a43ddcbc8a4a71b9))

#### `firebase_messaging_platform_interface` - `v3.5.2`

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

#### `firebase_messaging_web` - `v2.4.2`

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

#### `firebase_ml_model_downloader` - `v0.1.0+15`

 - **REFACTOR**: use `firebase.google.com` link for `homepage` in `pubspec.yaml` (#8736). ([f0ca0f19](https://github.com/firebase/flutterfire/commit/f0ca0f191714e0e53101219741d848428ff33e75))
 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))
 - **DOCS**: point to "firebase.google" domain for hyperlinks in the usage section of `README.md` files (for the missing packages) (#8818). ([5bda8c92](https://github.com/firebase/flutterfire/commit/5bda8c92be1651a941d1285d36e885ee0b967b11))

#### `firebase_ml_model_downloader_platform_interface` - `v0.1.1+8`

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

#### `firebase_performance` - `v0.8.0+14`

 - **REFACTOR**: use `firebase.google.com` link for `homepage` in `pubspec.yaml` (#8737). ([5d5d4d21](https://github.com/firebase/flutterfire/commit/5d5d4d213233158971d7cb896a250d050e95e1a6))
 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))
 - **DOCS**: point to "firebase.google" domain for hyperlinks in the usage section of `README.md` files (for the missing packages) (#8818). ([5bda8c92](https://github.com/firebase/flutterfire/commit/5bda8c92be1651a941d1285d36e885ee0b967b11))

#### `firebase_performance_platform_interface` - `v0.1.1+8`

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

#### `firebase_performance_web` - `v0.1.0+14`

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

#### `firebase_remote_config` - `v2.0.9`

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))
 - **FIX**: Provide firebase_remote_config as error code for android (#8717). ([2854cbcb](https://github.com/firebase/flutterfire/commit/2854cbcb5a2e604ace8dc55993893e5ffdbff5a8))
 - **DOCS**: point to "firebase.google" domain for hyperlinks in the usage section of `README.md` files (for the missing packages) (#8818). ([5bda8c92](https://github.com/firebase/flutterfire/commit/5bda8c92be1651a941d1285d36e885ee0b967b11))

#### `firebase_remote_config_platform_interface` - `v1.1.8`

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

#### `firebase_remote_config_web` - `v1.0.14`

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

#### `firebase_storage` - `v10.2.18`

 - **REFACTOR**: migrate from hash* to Object.hash* (#8797). ([3dfc0997](https://github.com/firebase/flutterfire/commit/3dfc0997050ee4351207c355b2c22b46885f971f))
 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))
 - **DOCS**: point to "firebase.google" domain for hyperlinks in the usage section of `README.md` files (#8814). ([78006e0d](https://github.com/firebase/flutterfire/commit/78006e0d5b9dce8038ce3606a43ddcbc8a4a71b9))

#### `firebase_storage_platform_interface` - `v4.1.8`

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

#### `firebase_storage_web` - `v3.2.17`

 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))

#### `flutterfire_ui` - `v0.4.2`

 - **REFACTOR**: migrate from hash* to Object.hash* (#8797). ([3dfc0997](https://github.com/firebase/flutterfire/commit/3dfc0997050ee4351207c355b2c22b46885f971f))
 - **REFACTOR**: use "firebase" instead of "FirebaseExtended" as organisation in all links for this repository (#8791). ([d90b8357](https://github.com/firebase/flutterfire/commit/d90b8357db01d65e753021358668f0b129713e6b))
 - **FIX**: fixed profile email modal overflow occurring on smaller devices (#8685). ([ed7add02](https://github.com/firebase/flutterfire/commit/ed7add025b1cb4accaa8163c5858d3025e87a62f))
 - **FEAT**: add Simplified Chinese localization support (#8867). ([2aecd483](https://github.com/firebase/flutterfire/commit/2aecd483430ef50f3a184a9992c4079710aa206a))
 - **FEAT**: Added Flexibility to the TableBuilder (#8539). ([78f93d69](https://github.com/firebase/flutterfire/commit/78f93d69806dc412dd055d0671e6d4c7a6507cec))
 - **DOCS**: Change Facebook Typo to Twitter in the documentation (#8824). ([f2ddb783](https://github.com/firebase/flutterfire/commit/f2ddb783aab4262fd2dd8f4be3819c00e10d4fca))


## 2022-05-26

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`cloud_functions` - `v3.2.16`](#cloud_functions---v3216)
 - [`firebase_app_check` - `v0.0.6+13`](#firebase_app_check---v00613)
 - [`firebase_auth` - `v3.3.19`](#firebase_auth---v3319)
 - [`firebase_core` - `v1.17.1`](#firebase_core---v1171)
 - [`firebase_crashlytics` - `v2.8.1`](#firebase_crashlytics---v281)
 - [`firebase_database` - `v9.0.15`](#firebase_database---v9015)
 - [`firebase_dynamic_links` - `v4.2.5`](#firebase_dynamic_links---v425)
 - [`firebase_in_app_messaging` - `v0.6.0+15`](#firebase_in_app_messaging---v06015)
 - [`firebase_messaging` - `v11.4.1`](#firebase_messaging---v1141)
 - [`firebase_ml_model_downloader` - `v0.1.0+14`](#firebase_ml_model_downloader---v01014)
 - [`firebase_remote_config` - `v2.0.8`](#firebase_remote_config---v208)
 - [`firebase_storage` - `v10.2.17`](#firebase_storage---v10217)
 - [`flutterfire_ui` - `v0.4.1+2`](#flutterfire_ui---v0412)
 - [`firebase_in_app_messaging_platform_interface` - `v0.2.1+7`](#firebase_in_app_messaging_platform_interface---v0217)
 - [`firebase_crashlytics_platform_interface` - `v3.2.7`](#firebase_crashlytics_platform_interface---v327)
 - [`firebase_auth_platform_interface` - `v6.2.7`](#firebase_auth_platform_interface---v627)
 - [`firebase_auth_web` - `v3.3.16`](#firebase_auth_web---v3316)
 - [`firebase_remote_config_platform_interface` - `v1.1.7`](#firebase_remote_config_platform_interface---v117)
 - [`firebase_remote_config_web` - `v1.0.13`](#firebase_remote_config_web---v1013)
 - [`firebase_dynamic_links_platform_interface` - `v0.2.3+3`](#firebase_dynamic_links_platform_interface---v0233)
 - [`firebase_database_web` - `v0.2.0+14`](#firebase_database_web---v02014)
 - [`firebase_database_platform_interface` - `v0.2.1+7`](#firebase_database_platform_interface---v0217)
 - [`cloud_firestore_web` - `v2.6.16`](#cloud_firestore_web---v2616)
 - [`cloud_firestore_platform_interface` - `v5.5.7`](#cloud_firestore_platform_interface---v557)
 - [`cloud_firestore` - `v3.1.17`](#cloud_firestore---v3117)
 - [`firebase_app_installations_web` - `v0.1.0+14`](#firebase_app_installations_web---v01014)
 - [`firebase_app_installations_platform_interface` - `v0.1.1+7`](#firebase_app_installations_platform_interface---v0117)
 - [`firebase_app_installations` - `v0.1.0+14`](#firebase_app_installations---v01014)
 - [`firebase_messaging_web` - `v2.4.1`](#firebase_messaging_web---v241)
 - [`firebase_messaging_platform_interface` - `v3.5.1`](#firebase_messaging_platform_interface---v351)
 - [`firebase_analytics_platform_interface` - `v3.1.7`](#firebase_analytics_platform_interface---v317)
 - [`firebase_analytics` - `v9.1.9`](#firebase_analytics---v919)
 - [`firebase_app_check_platform_interface` - `v0.0.4+7`](#firebase_app_check_platform_interface---v0047)
 - [`firebase_ml_model_downloader_platform_interface` - `v0.1.1+7`](#firebase_ml_model_downloader_platform_interface---v0117)
 - [`firebase_analytics_web` - `v0.4.0+14`](#firebase_analytics_web---v04014)
 - [`firebase_app_check_web` - `v0.0.5+13`](#firebase_app_check_web---v00513)
 - [`cloud_functions_platform_interface` - `v5.1.7`](#cloud_functions_platform_interface---v517)
 - [`cloud_functions_web` - `v4.2.15`](#cloud_functions_web---v4215)
 - [`firebase_storage_web` - `v3.2.16`](#firebase_storage_web---v3216)
 - [`firebase_performance_platform_interface` - `v0.1.1+7`](#firebase_performance_platform_interface---v0117)
 - [`firebase_storage_platform_interface` - `v4.1.7`](#firebase_storage_platform_interface---v417)
 - [`firebase_performance_web` - `v0.1.0+13`](#firebase_performance_web---v01013)
 - [`firebase_performance` - `v0.8.0+13`](#firebase_performance---v08013)
 - [`cloud_firestore_odm` - `v1.0.0-dev.17`](#cloud_firestore_odm---v100-dev17)
 - [`cloud_firestore_odm_generator` - `v1.0.0-dev.17`](#cloud_firestore_odm_generator---v100-dev17)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `firebase_in_app_messaging_platform_interface` - `v0.2.1+7`
 - `firebase_crashlytics_platform_interface` - `v3.2.7`
 - `firebase_auth_platform_interface` - `v6.2.7`
 - `firebase_auth_web` - `v3.3.16`
 - `firebase_remote_config_platform_interface` - `v1.1.7`
 - `firebase_remote_config_web` - `v1.0.13`
 - `firebase_dynamic_links_platform_interface` - `v0.2.3+3`
 - `firebase_database_web` - `v0.2.0+14`
 - `firebase_database_platform_interface` - `v0.2.1+7`
 - `cloud_firestore_web` - `v2.6.16`
 - `cloud_firestore_platform_interface` - `v5.5.7`
 - `cloud_firestore` - `v3.1.17`
 - `firebase_app_installations_web` - `v0.1.0+14`
 - `firebase_app_installations_platform_interface` - `v0.1.1+7`
 - `firebase_app_installations` - `v0.1.0+14`
 - `firebase_messaging_web` - `v2.4.1`
 - `firebase_messaging_platform_interface` - `v3.5.1`
 - `firebase_analytics_platform_interface` - `v3.1.7`
 - `firebase_analytics` - `v9.1.9`
 - `firebase_app_check_platform_interface` - `v0.0.4+7`
 - `firebase_ml_model_downloader_platform_interface` - `v0.1.1+7`
 - `firebase_analytics_web` - `v0.4.0+14`
 - `firebase_app_check_web` - `v0.0.5+13`
 - `cloud_functions_platform_interface` - `v5.1.7`
 - `cloud_functions_web` - `v4.2.15`
 - `firebase_storage_web` - `v3.2.16`
 - `firebase_performance_platform_interface` - `v0.1.1+7`
 - `firebase_storage_platform_interface` - `v4.1.7`
 - `firebase_performance_web` - `v0.1.0+13`
 - `firebase_performance` - `v0.8.0+13`
 - `cloud_firestore_odm` - `v1.0.0-dev.17`
 - `cloud_firestore_odm_generator` - `v1.0.0-dev.17`

---

#### `cloud_functions` - `v3.2.16`

 - **DOCS**: use camel case style for "FlutterFire" in `README.md` (#8746). ([53813627](https://github.com/firebase/flutterfire/commit/53813627720e1e1ad729839519f7374ebc91470f))

#### `firebase_app_check` - `v0.0.6+13`

 - **DOCS**: use camel case style for "FlutterFire" in `README.md` (#8747). ([e2a022d7](https://github.com/firebase/flutterfire/commit/e2a022d7427817002e4114eb7434aa6e53384891))

#### `firebase_auth` - `v3.3.19`

 - **DOCS**: use camel case style for "FlutterFire" in `README.md` (#8748). ([c6ff0b21](https://github.com/firebase/flutterfire/commit/c6ff0b21352eb0f9a9a576ca7ef737d203292a58))

#### `firebase_core` - `v1.17.1`

 - **DOCS**: use camel case style for "FlutterFire" in `README.md` (#8749). ([41462a42](https://github.com/firebase/flutterfire/commit/41462a423ad783d20e5d303ed41898b061bccc48))

#### `firebase_crashlytics` - `v2.8.1`

 - **DOCS**: use camel case style for "FlutterFire" in `README.md` (#8750). ([e9e1c1bf](https://github.com/firebase/flutterfire/commit/e9e1c1bf19d32e5b8967da162b03d0254843a836))

#### `firebase_database` - `v9.0.15`

 - **REFACTOR**: use `firebase.google.com` link for `homepage` in `pubspec.yaml` (#8732). ([63aa1011](https://github.com/firebase/flutterfire/commit/63aa10118e3fa541b276fed5828bd7db368c5ebd))

#### `firebase_dynamic_links` - `v4.2.5`

 - **REFACTOR**: use `firebase.google.com` link for `homepage` in `pubspec.yaml` (#8733). ([a11bd602](https://github.com/firebase/flutterfire/commit/a11bd6021a3e915bf36f0db295b45ee8a3f16517))

#### `firebase_in_app_messaging` - `v0.6.0+15`

 - **REFACTOR**: use `firebase.google.com` link for `homepage` in `pubspec.yaml` (#8734). ([9ce47865](https://github.com/firebase/flutterfire/commit/9ce47865e4fcba0aaf1a4558ba7ede13abcde21d))

#### `firebase_messaging` - `v11.4.1`

 - **REFACTOR**: use `firebase.google.com` link for `homepage` in `pubspec.yaml` (#8735). ([b2cf87a5](https://github.com/firebase/flutterfire/commit/b2cf87a5d96457bf49b9dd04d6087768bfe6ad95))
 - **FIX**: check `userInfo` for "aps.notification" property presence for firing data only messages. (#8759). ([9eb99674](https://github.com/firebase/flutterfire/commit/9eb996748f4ddae8a34a2306b51af10b4c066039))

#### `firebase_ml_model_downloader` - `v0.1.0+14`

 - **DOCS**: use camel case style for "FlutterFire" in `README.md` (#8751). ([e1e42eb9](https://github.com/firebase/flutterfire/commit/e1e42eb97772a86bf5e35d0f3be0376225a5f1d6))

#### `firebase_remote_config` - `v2.0.8`

 - **REFACTOR**: use `firebase.google.com` link for `homepage` in `pubspec.yaml` (#8738). ([f5ca08b2](https://github.com/firebase/flutterfire/commit/f5ca08b2ca68e674f6c59c458ec26126c9e1b002))

#### `firebase_storage` - `v10.2.17`

 - **DOCS**: use camel case style for "FlutterFire" in `README.md` (#8752). ([5c5dcaf1](https://github.com/firebase/flutterfire/commit/5c5dcaf1909dacf293fec5e79461d43468a13279))

#### `flutterfire_ui` - `v0.4.1+2`

 - **FIX**: correctly fix lint error from issue #8651 for dart `2.16` (#8713). ([666b1973](https://github.com/firebase/flutterfire/commit/666b1973c68cd5e60ba254a889136c922fd73500))


## 2022-05-19

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`cloud_firestore` - `v3.1.16`](#cloud_firestore---v3116)
 - [`firebase_dynamic_links` - `v4.2.4`](#firebase_dynamic_links---v424)
 - [`flutterfire_ui` - `v0.4.1+1`](#flutterfire_ui---v0411)
 - [`cloud_firestore_odm` - `v1.0.0-dev.16`](#cloud_firestore_odm---v100-dev16)
 - [`cloud_firestore_odm_generator` - `v1.0.0-dev.16`](#cloud_firestore_odm_generator---v100-dev16)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flutterfire_ui` - `v0.4.1+1`
 - `cloud_firestore_odm` - `v1.0.0-dev.16`
 - `cloud_firestore_odm_generator` - `v1.0.0-dev.16`

---

#### `cloud_firestore` - `v3.1.16`

 - **REFACTOR**: remove deprecated `Tasks.call` for android and replace with `TaskCompletionSource`. (#8522). ([45e27201](https://github.com/firebase/flutterfire/commit/45e27201480088fab71af60963001baeae61d80d))

#### `firebase_dynamic_links` - `v4.2.4`

 - **FIX**: `getInitialLink()` returns `null` on 2nd call. (#8621). ([a83ee58e](https://github.com/firebase/flutterfire/commit/a83ee58e56879b88b2886a6e5f5be549ee403b23))


## 2022-05-13

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`cloud_firestore_odm` - `v1.0.0-dev.15`](#cloud_firestore_odm---v100-dev15)
 - [`cloud_firestore_odm_generator` - `v1.0.0-dev.15`](#cloud_firestore_odm_generator---v100-dev15)
 - [`cloud_firestore_platform_interface` - `v5.5.6`](#cloud_firestore_platform_interface---v556)
 - [`firebase_auth_platform_interface` - `v6.2.6`](#firebase_auth_platform_interface---v626)
 - [`firebase_core` - `v1.17.0`](#firebase_core---v1170)
 - [`firebase_core_platform_interface` - `v4.4.0`](#firebase_core_platform_interface---v440)
 - [`firebase_crashlytics` - `v2.8.0`](#firebase_crashlytics---v280)
 - [`firebase_database_platform_interface` - `v0.2.1+6`](#firebase_database_platform_interface---v0216)
 - [`firebase_dynamic_links_platform_interface` - `v0.2.3+2`](#firebase_dynamic_links_platform_interface---v0232)
 - [`firebase_messaging` - `v11.4.0`](#firebase_messaging---v1140)
 - [`firebase_messaging_platform_interface` - `v3.5.0`](#firebase_messaging_platform_interface---v350)
 - [`firebase_messaging_web` - `v2.4.0`](#firebase_messaging_web---v240)
 - [`flutterfire_ui` - `v0.4.1`](#flutterfire_ui---v041)
 - [`cloud_firestore_web` - `v2.6.15`](#cloud_firestore_web---v2615)
 - [`cloud_firestore` - `v3.1.15`](#cloud_firestore---v3115)
 - [`firebase_auth` - `v3.3.18`](#firebase_auth---v3318)
 - [`firebase_auth_web` - `v3.3.15`](#firebase_auth_web---v3315)
 - [`firebase_in_app_messaging` - `v0.6.0+14`](#firebase_in_app_messaging---v06014)
 - [`firebase_in_app_messaging_platform_interface` - `v0.2.1+6`](#firebase_in_app_messaging_platform_interface---v0216)
 - [`firebase_crashlytics_platform_interface` - `v3.2.6`](#firebase_crashlytics_platform_interface---v326)
 - [`firebase_remote_config` - `v2.0.7`](#firebase_remote_config---v207)
 - [`firebase_remote_config_web` - `v1.0.12`](#firebase_remote_config_web---v1012)
 - [`firebase_remote_config_platform_interface` - `v1.1.6`](#firebase_remote_config_platform_interface---v116)
 - [`firebase_database_web` - `v0.2.0+13`](#firebase_database_web---v02013)
 - [`firebase_database` - `v9.0.14`](#firebase_database---v9014)
 - [`firebase_dynamic_links` - `v4.2.3`](#firebase_dynamic_links---v423)
 - [`firebase_app_installations_web` - `v0.1.0+13`](#firebase_app_installations_web---v01013)
 - [`firebase_app_installations` - `v0.1.0+13`](#firebase_app_installations---v01013)
 - [`firebase_app_installations_platform_interface` - `v0.1.1+6`](#firebase_app_installations_platform_interface---v0116)
 - [`firebase_analytics_platform_interface` - `v3.1.6`](#firebase_analytics_platform_interface---v316)
 - [`firebase_analytics` - `v9.1.8`](#firebase_analytics---v918)
 - [`firebase_analytics_web` - `v0.4.0+13`](#firebase_analytics_web---v04013)
 - [`firebase_ml_model_downloader` - `v0.1.0+13`](#firebase_ml_model_downloader---v01013)
 - [`firebase_ml_model_downloader_platform_interface` - `v0.1.1+6`](#firebase_ml_model_downloader_platform_interface---v0116)
 - [`firebase_app_check_platform_interface` - `v0.0.4+6`](#firebase_app_check_platform_interface---v0046)
 - [`firebase_app_check` - `v0.0.6+12`](#firebase_app_check---v00612)
 - [`firebase_app_check_web` - `v0.0.5+12`](#firebase_app_check_web---v00512)
 - [`cloud_functions_web` - `v4.2.14`](#cloud_functions_web---v4214)
 - [`cloud_functions` - `v3.2.15`](#cloud_functions---v3215)
 - [`cloud_functions_platform_interface` - `v5.1.6`](#cloud_functions_platform_interface---v516)
 - [`firebase_storage_web` - `v3.2.15`](#firebase_storage_web---v3215)
 - [`firebase_storage_platform_interface` - `v4.1.6`](#firebase_storage_platform_interface---v416)
 - [`firebase_storage` - `v10.2.16`](#firebase_storage---v10216)
 - [`firebase_performance_platform_interface` - `v0.1.1+6`](#firebase_performance_platform_interface---v0116)
 - [`firebase_performance_web` - `v0.1.0+12`](#firebase_performance_web---v01012)
 - [`firebase_performance` - `v0.8.0+12`](#firebase_performance---v08012)
 - [`firebase_core_web` - `v1.6.4`](#firebase_core_web---v164)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `cloud_firestore_web` - `v2.6.15`
 - `cloud_firestore` - `v3.1.15`
 - `firebase_auth` - `v3.3.18`
 - `firebase_auth_web` - `v3.3.15`
 - `firebase_in_app_messaging` - `v0.6.0+14`
 - `firebase_in_app_messaging_platform_interface` - `v0.2.1+6`
 - `firebase_crashlytics_platform_interface` - `v3.2.6`
 - `firebase_remote_config` - `v2.0.7`
 - `firebase_remote_config_web` - `v1.0.12`
 - `firebase_remote_config_platform_interface` - `v1.1.6`
 - `firebase_database_web` - `v0.2.0+13`
 - `firebase_database` - `v9.0.14`
 - `firebase_dynamic_links` - `v4.2.3`
 - `firebase_app_installations_web` - `v0.1.0+13`
 - `firebase_app_installations` - `v0.1.0+13`
 - `firebase_app_installations_platform_interface` - `v0.1.1+6`
 - `firebase_analytics_platform_interface` - `v3.1.6`
 - `firebase_analytics` - `v9.1.8`
 - `firebase_analytics_web` - `v0.4.0+13`
 - `firebase_ml_model_downloader` - `v0.1.0+13`
 - `firebase_ml_model_downloader_platform_interface` - `v0.1.1+6`
 - `firebase_app_check_platform_interface` - `v0.0.4+6`
 - `firebase_app_check` - `v0.0.6+12`
 - `firebase_app_check_web` - `v0.0.5+12`
 - `cloud_functions_web` - `v4.2.14`
 - `cloud_functions` - `v3.2.15`
 - `cloud_functions_platform_interface` - `v5.1.6`
 - `firebase_storage_web` - `v3.2.15`
 - `firebase_storage_platform_interface` - `v4.1.6`
 - `firebase_storage` - `v10.2.16`
 - `firebase_performance_platform_interface` - `v0.1.1+6`
 - `firebase_performance_web` - `v0.1.0+12`
 - `firebase_performance` - `v0.8.0+12`
 - `firebase_core_web` - `v1.6.4`

---

#### `cloud_firestore_odm` - `v1.0.0-dev.15`

 - **FEAT**: Assert that collection.doc(id) does not point to a separate collection ([#8676](https://github.com/firebase/flutterfire/issues/8676)). ([0808205b](https://github.com/firebase/flutterfire/commit/0808205bdca03fc913015f00f5ffc2e1d018adb9))

#### `cloud_firestore_odm_generator` - `v1.0.0-dev.15`

 - **FIX**: ODM should no-longer generates update/query functions for nested objects ([#8661](https://github.com/firebase/flutterfire/issues/8661)). ([84eeed2e](https://github.com/firebase/flutterfire/commit/84eeed2ec8da3aac87befd2028f8052005319730))
 - **FEAT**: Assert that collection.doc(id) does not point to a separate collection ([#8676](https://github.com/firebase/flutterfire/issues/8676)). ([0808205b](https://github.com/firebase/flutterfire/commit/0808205bdca03fc913015f00f5ffc2e1d018adb9))

#### `cloud_firestore_platform_interface` - `v5.5.6`

 - **REFACTOR**: fix analyzer issues introduced in Flutter 3.0.0 ([#8655](https://github.com/firebase/flutterfire/issues/8655)). ([b05d7fa1](https://github.com/firebase/flutterfire/commit/b05d7fa1ed56ab1bbceb02fec299800bce68a703))

#### `firebase_auth_platform_interface` - `v6.2.6`

 - **REFACTOR**: fix analyzer issues introduced in Flutter 3.0.0 ([#8653](https://github.com/firebase/flutterfire/issues/8653)). ([74e58171](https://github.com/firebase/flutterfire/commit/74e5817159f18934ed0cd803f410ec96b372316a))

#### `firebase_core` - `v1.17.0`

 - **REFACTOR**: remove deprecated `Tasks.call` for android and replace with `TaskCompletionSource`. ([#8581](https://github.com/firebase/flutterfire/issues/8581)). ([374c9df3](https://github.com/firebase/flutterfire/commit/374c9df33bbb6b354ea526dcc6cc7812fa4452c0))
 - **FEAT**: bump Firebase Android SDK to 30.0.0 ([#8617](https://github.com/firebase/flutterfire/issues/8617)). ([72158aaf](https://github.com/firebase/flutterfire/commit/72158aaf9721dbf5f20c362f0c99853273507538))
 - **FEAT**: allow initializing default Firebase apps via `FirebaseOptions.fromResource` on Android ([#8566](https://github.com/firebase/flutterfire/issues/8566)). ([30216c4a](https://github.com/firebase/flutterfire/commit/30216c4a4c06c20f9c4c2b9a235a4aa9a48816a0))

#### `firebase_core_platform_interface` - `v4.4.0`

 - **FEAT**: allow initializing default Firebase apps via `FirebaseOptions.fromResource` on Android ([#8566](https://github.com/firebase/flutterfire/issues/8566)). ([30216c4a](https://github.com/firebase/flutterfire/commit/30216c4a4c06c20f9c4c2b9a235a4aa9a48816a0))

#### `firebase_crashlytics` - `v2.8.0`

 - **REFACTOR**: remove deprecated `Tasks.call` for android and replace with `TaskCompletionSource`. ([#8582](https://github.com/firebase/flutterfire/issues/8582)). ([9539c92a](https://github.com/firebase/flutterfire/commit/9539c92a53f73bf57b9c61ae9e0ce5042b4b8ca4))
 - **FIX**: symlink `ExceptionModel_Platform.h` to macOS. ([#8570](https://github.com/firebase/flutterfire/issues/8570)). ([9991b7a5](https://github.com/firebase/flutterfire/commit/9991b7a5389738a7bbba8f2210f8379b887d90e7))
 - **FEAT**: bump Firebase Android SDK to 30.0.0 ([#8617](https://github.com/firebase/flutterfire/issues/8617)). ([72158aaf](https://github.com/firebase/flutterfire/commit/72158aaf9721dbf5f20c362f0c99853273507538))

#### `firebase_database_platform_interface` - `v0.2.1+6`

 - **REFACTOR**: fix analyzer issue introduced in Flutter 3.0.0 ([#8652](https://github.com/firebase/flutterfire/issues/8652)). ([b781153a](https://github.com/firebase/flutterfire/commit/b781153ac65df629c0a181219bf0b01999a5fa59))

#### `firebase_dynamic_links_platform_interface` - `v0.2.3+2`

 - **REFACTOR**: fix analyzer issue introduced in Flutter 3.0.0 ([#8654](https://github.com/firebase/flutterfire/issues/8654)). ([55d8fb59](https://github.com/firebase/flutterfire/commit/55d8fb593acc8e50b3cbd98ab9645ca73e7af936))

#### `firebase_messaging` - `v11.4.0`

 - **FIX**: ensure silent foreground messages for iOS are called via event channel. ([#8635](https://github.com/firebase/flutterfire/issues/8635)). ([abb91e48](https://github.com/firebase/flutterfire/commit/abb91e4861b769485878a0f165d6ba8a9604de5a))
 - **FEAT**: retrieve `timeSensitiveSetting` for iOS 15+. ([#8532](https://github.com/firebase/flutterfire/issues/8532)). ([14b38da3](https://github.com/firebase/flutterfire/commit/14b38da31f364ad35be20c5df9cd633c613d8067))

#### `firebase_messaging_platform_interface` - `v3.5.0`

 - **FEAT**: retrieve `timeSensitiveSetting` for iOS 15+. ([#8532](https://github.com/firebase/flutterfire/issues/8532)). ([14b38da3](https://github.com/firebase/flutterfire/commit/14b38da31f364ad35be20c5df9cd633c613d8067))

#### `firebase_messaging_web` - `v2.4.0`

 - **FEAT**: retrieve `timeSensitiveSetting` for iOS 15+. ([#8532](https://github.com/firebase/flutterfire/issues/8532)). ([14b38da3](https://github.com/firebase/flutterfire/commit/14b38da31f364ad35be20c5df9cd633c613d8067))

#### `flutterfire_ui` - `v0.4.1`

 - **FIX**: flutterfire_ui README links ([#8630](https://github.com/firebase/flutterfire/issues/8630)). ([ba5b58af](https://github.com/firebase/flutterfire/commit/ba5b58af354c762a4d4e4fe11e4017730bfa6c9e))
 - **FIX**: use `EmailVerificationScreen.actionCodeSettings` & and fix `flutter analyze` with Flutter 3.0.0 ([#8651](https://github.com/firebase/flutterfire/issues/8651)). ([f12f1e24](https://github.com/firebase/flutterfire/commit/f12f1e24e85dcea014374752a9d58142db33a5ab))
 - **FIX**: set the default variant of LoadingButton to outlined ([#8443](https://github.com/firebase/flutterfire/issues/8443)) ([#8545](https://github.com/firebase/flutterfire/issues/8545)). ([518cdcee](https://github.com/firebase/flutterfire/commit/518cdcee7c43c995b4067857c38bff0a023302ee))
 - **FEAT**: add styling APIs `FlutterFireUITheme` and `FlutterFireUIStyle` ([#8580](https://github.com/firebase/flutterfire/issues/8580)). ([83e2d455](https://github.com/firebase/flutterfire/commit/83e2d455d3a083886168b4c115191b06e307a41f))
 - **DOCS**: Copy FlutterFire UI & ODM docs to package dirs ([#8574](https://github.com/firebase/flutterfire/issues/8574)). ([c76f0d9b](https://github.com/firebase/flutterfire/commit/c76f0d9bf954497923464e045671fd73be9b88c4))


## 2022-05-03

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`firebase_core` - `v1.16.0`](#firebase_core---v1160)
 - [`firebase_core_platform_interface` - `v4.3.0`](#firebase_core_platform_interface---v430)
 - [`firebase_messaging` - `v11.3.0`](#firebase_messaging---v1130)
 - [`firebase_messaging_platform_interface` - `v3.4.0`](#firebase_messaging_platform_interface---v340)
 - [`firebase_messaging_web` - `v2.3.0`](#firebase_messaging_web---v230)
 - [`firebase_crashlytics` - `v2.7.2`](#firebase_crashlytics---v272)
 - [`firebase_in_app_messaging` - `v0.6.0+13`](#firebase_in_app_messaging---v06013)
 - [`firebase_in_app_messaging_platform_interface` - `v0.2.1+5`](#firebase_in_app_messaging_platform_interface---v0215)
 - [`firebase_database_web` - `v0.2.0+12`](#firebase_database_web---v02012)
 - [`firebase_crashlytics_platform_interface` - `v3.2.5`](#firebase_crashlytics_platform_interface---v325)
 - [`firebase_database` - `v9.0.13`](#firebase_database---v9013)
 - [`firebase_dynamic_links_platform_interface` - `v0.2.3+1`](#firebase_dynamic_links_platform_interface---v0231)
 - [`firebase_database_platform_interface` - `v0.2.1+5`](#firebase_database_platform_interface---v0215)
 - [`cloud_firestore_web` - `v2.6.14`](#cloud_firestore_web---v2614)
 - [`firebase_auth` - `v3.3.17`](#firebase_auth---v3317)
 - [`firebase_auth_platform_interface` - `v6.2.5`](#firebase_auth_platform_interface---v625)
 - [`firebase_auth_web` - `v3.3.14`](#firebase_auth_web---v3314)
 - [`firebase_analytics_platform_interface` - `v3.1.5`](#firebase_analytics_platform_interface---v315)
 - [`cloud_firestore` - `v3.1.14`](#cloud_firestore---v3114)
 - [`firebase_app_installations` - `v0.1.0+12`](#firebase_app_installations---v01012)
 - [`firebase_remote_config` - `v2.0.6`](#firebase_remote_config---v206)
 - [`cloud_functions_web` - `v4.2.13`](#cloud_functions_web---v4213)
 - [`firebase_dynamic_links` - `v4.2.2`](#firebase_dynamic_links---v422)
 - [`firebase_app_check_platform_interface` - `v0.0.4+5`](#firebase_app_check_platform_interface---v0045)
 - [`firebase_app_check` - `v0.0.6+11`](#firebase_app_check---v00611)
 - [`firebase_remote_config_web` - `v1.0.11`](#firebase_remote_config_web---v1011)
 - [`firebase_remote_config_platform_interface` - `v1.1.5`](#firebase_remote_config_platform_interface---v115)
 - [`cloud_firestore_platform_interface` - `v5.5.5`](#cloud_firestore_platform_interface---v555)
 - [`cloud_functions` - `v3.2.14`](#cloud_functions---v3214)
 - [`cloud_functions_platform_interface` - `v5.1.5`](#cloud_functions_platform_interface---v515)
 - [`firebase_app_check_web` - `v0.0.5+11`](#firebase_app_check_web---v00511)
 - [`firebase_app_installations_web` - `v0.1.0+12`](#firebase_app_installations_web---v01012)
 - [`firebase_app_installations_platform_interface` - `v0.1.1+5`](#firebase_app_installations_platform_interface---v0115)
 - [`firebase_analytics` - `v9.1.7`](#firebase_analytics---v917)
 - [`firebase_storage_platform_interface` - `v4.1.5`](#firebase_storage_platform_interface---v415)
 - [`firebase_performance_platform_interface` - `v0.1.1+5`](#firebase_performance_platform_interface---v0115)
 - [`firebase_performance_web` - `v0.1.0+11`](#firebase_performance_web---v01011)
 - [`firebase_analytics_web` - `v0.4.0+12`](#firebase_analytics_web---v04012)
 - [`firebase_storage_web` - `v3.2.14`](#firebase_storage_web---v3214)
 - [`flutterfire_ui` - `v0.4.0+5`](#flutterfire_ui---v0405)
 - [`firebase_storage` - `v10.2.15`](#firebase_storage---v10215)
 - [`firebase_performance` - `v0.8.0+11`](#firebase_performance---v08011)
 - [`firebase_ml_model_downloader_platform_interface` - `v0.1.1+5`](#firebase_ml_model_downloader_platform_interface---v0115)
 - [`firebase_ml_model_downloader` - `v0.1.0+12`](#firebase_ml_model_downloader---v01012)
 - [`cloud_firestore_odm` - `v1.0.0-dev.14`](#cloud_firestore_odm---v100-dev14)
 - [`cloud_firestore_odm_generator` - `v1.0.0-dev.14`](#cloud_firestore_odm_generator---v100-dev14)
 - [`firebase_core_web` - `v1.6.3`](#firebase_core_web---v163)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `firebase_crashlytics` - `v2.7.2`
 - `firebase_in_app_messaging` - `v0.6.0+13`
 - `firebase_in_app_messaging_platform_interface` - `v0.2.1+5`
 - `firebase_database_web` - `v0.2.0+12`
 - `firebase_crashlytics_platform_interface` - `v3.2.5`
 - `firebase_database` - `v9.0.13`
 - `firebase_dynamic_links_platform_interface` - `v0.2.3+1`
 - `firebase_database_platform_interface` - `v0.2.1+5`
 - `cloud_firestore_web` - `v2.6.14`
 - `firebase_auth` - `v3.3.17`
 - `firebase_auth_platform_interface` - `v6.2.5`
 - `firebase_auth_web` - `v3.3.14`
 - `firebase_analytics_platform_interface` - `v3.1.5`
 - `cloud_firestore` - `v3.1.14`
 - `firebase_app_installations` - `v0.1.0+12`
 - `firebase_remote_config` - `v2.0.6`
 - `cloud_functions_web` - `v4.2.13`
 - `firebase_dynamic_links` - `v4.2.2`
 - `firebase_app_check_platform_interface` - `v0.0.4+5`
 - `firebase_app_check` - `v0.0.6+11`
 - `firebase_remote_config_web` - `v1.0.11`
 - `firebase_remote_config_platform_interface` - `v1.1.5`
 - `cloud_firestore_platform_interface` - `v5.5.5`
 - `cloud_functions` - `v3.2.14`
 - `cloud_functions_platform_interface` - `v5.1.5`
 - `firebase_app_check_web` - `v0.0.5+11`
 - `firebase_app_installations_web` - `v0.1.0+12`
 - `firebase_app_installations_platform_interface` - `v0.1.1+5`
 - `firebase_analytics` - `v9.1.7`
 - `firebase_storage_platform_interface` - `v4.1.5`
 - `firebase_performance_platform_interface` - `v0.1.1+5`
 - `firebase_performance_web` - `v0.1.0+11`
 - `firebase_analytics_web` - `v0.4.0+12`
 - `firebase_storage_web` - `v3.2.14`
 - `flutterfire_ui` - `v0.4.0+5`
 - `firebase_storage` - `v10.2.15`
 - `firebase_performance` - `v0.8.0+11`
 - `firebase_ml_model_downloader_platform_interface` - `v0.1.1+5`
 - `firebase_ml_model_downloader` - `v0.1.0+12`
 - `cloud_firestore_odm` - `v1.0.0-dev.14`
 - `cloud_firestore_odm_generator` - `v1.0.0-dev.14`
 - `firebase_core_web` - `v1.6.3`

---

#### `firebase_core` - `v1.16.0`

 - **FEAT**: allow initializing default Firebase apps via `FirebaseOptions.fromResource` on Android (#8566). ([30216c4a](https://github.com/firebase/flutterfire/commit/30216c4a4c06c20f9c4c2b9a235a4aa9a48816a0))

#### `firebase_core_platform_interface` - `v4.3.0`

 - **FEAT**: allow initializing default Firebase apps via `FirebaseOptions.fromResource` on Android (#8566). ([30216c4a](https://github.com/firebase/flutterfire/commit/30216c4a4c06c20f9c4c2b9a235a4aa9a48816a0))

#### `firebase_messaging` - `v11.3.0`

 - **FEAT**: retrieve `timeSensitiveSetting` for iOS 15+. (#8532). ([14b38da3](https://github.com/firebase/flutterfire/commit/14b38da31f364ad35be20c5df9cd633c613d8067))

#### `firebase_messaging_platform_interface` - `v3.4.0`

 - **FEAT**: retrieve `timeSensitiveSetting` for iOS 15+. (#8532). ([14b38da3](https://github.com/firebase/flutterfire/commit/14b38da31f364ad35be20c5df9cd633c613d8067))

#### `firebase_messaging_web` - `v2.3.0`

 - **FEAT**: retrieve `timeSensitiveSetting` for iOS 15+. (#8532). ([14b38da3](https://github.com/firebase/flutterfire/commit/14b38da31f364ad35be20c5df9cd633c613d8067))


## 2022-04-29

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`firebase_crashlytics` - `v2.7.1`](#firebase_crashlytics---v271)

---

#### `firebase_crashlytics` - `v2.7.1`

 - **FIX**: re-add support for `recordFlutterFatalError` method from previous EAP API (#8550). ([8ef8b55c](https://github.com/firebase/flutterfire/commit/8ef8b55c113f24abac783170723c7f784f5d1fe5))


## 2022-04-29

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`firebase_crashlytics` - `v2.7.0`](#firebase_crashlytics---v270)

---

#### `firebase_crashlytics` - `v2.7.0`

 - **FEAT**: add support for on-demand exception reporting (#8540). ([dfec7d60](https://github.com/firebase/flutterfire/commit/dfec7d60592abe0a5c6523e13feabffb8b03020b))


## 2022-04-27

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`firebase_auth` - `v3.3.16`](#firebase_auth---v3316)
 - [`firebase_dynamic_links` - `v4.2.1`](#firebase_dynamic_links---v421)
 - [`firebase_messaging` - `v11.2.15`](#firebase_messaging---v11215)
 - [`firebase_messaging_platform_interface` - `v3.3.1`](#firebase_messaging_platform_interface---v331)
 - [`firebase_storage` - `v10.2.14`](#firebase_storage---v10214)
 - [`flutterfire_ui` - `v0.4.0+4`](#flutterfire_ui---v0404)
 - [`firebase_messaging_web` - `v2.2.13`](#firebase_messaging_web---v2213)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `flutterfire_ui` - `v0.4.0+4`
 - `firebase_messaging_web` - `v2.2.13`

---

#### `firebase_auth` - `v3.3.16`

 - **REFACTOR**: remove deprecated `Tasks.call()` API from Android. (#8452). ([3e92496b](https://github.com/firebase/flutterfire/commit/3e92496b2783ec149258c22d3167c5388dcb1c40))

#### `firebase_dynamic_links` - `v4.2.1`

 - **REFACTOR**: Update deprecated API for dynamic links example app. (#8519). ([c5d288b3](https://github.com/firebase/flutterfire/commit/c5d288b388cfd4180896ef9fc2a004c84ccbc017))

#### `firebase_messaging` - `v11.2.15`

 - **REFACTOR**: Remove deprecated `Tasks.call()` API from android. (#8449). ([0510d113](https://github.com/firebase/flutterfire/commit/0510d113dd279d6f55d889e522e74781d8fbb845))

#### `firebase_messaging_platform_interface` - `v3.3.1`

 - **FIX**: prevent isolate callback removal during split debug symbols (#8521). ([45ca7aeb](https://github.com/firebase/flutterfire/commit/45ca7aeb50920cea0ba5784e16a5b78adac014f3))

#### `firebase_storage` - `v10.2.14`

 - **REFACTOR**: Remove deprecated `Tasks.call()` API from android. (#8421). ([461bba5a](https://github.com/firebase/flutterfire/commit/461bba5a510b341b3b9bd414c9412944714e9305))


## 2022-04-21

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`cloud_firestore_odm` - `v1.0.0-dev.13`](#cloud_firestore_odm---v100-dev13)
 - [`cloud_firestore_odm_generator` - `v1.0.0-dev.13`](#cloud_firestore_odm_generator---v100-dev13)
 - [`firebase_analytics` - `v9.1.6`](#firebase_analytics---v916)
 - [`firebase_auth` - `v3.3.15`](#firebase_auth---v3315)
 - [`firebase_core` - `v1.15.0`](#firebase_core---v1150)
 - [`firebase_dynamic_links` - `v4.2.0`](#firebase_dynamic_links---v420)
 - [`firebase_dynamic_links_platform_interface` - `v0.2.3`](#firebase_dynamic_links_platform_interface---v023)
 - [`firebase_messaging_platform_interface` - `v3.3.0`](#firebase_messaging_platform_interface---v330)
 - [`flutterfire_ui` - `v0.4.0+3`](#flutterfire_ui---v0403)
 - [`firebase_crashlytics` - `v2.6.3`](#firebase_crashlytics---v263)
 - [`firebase_in_app_messaging_platform_interface` - `v0.2.1+4`](#firebase_in_app_messaging_platform_interface---v0214)
 - [`firebase_in_app_messaging` - `v0.6.0+12`](#firebase_in_app_messaging---v06012)
 - [`firebase_crashlytics_platform_interface` - `v3.2.4`](#firebase_crashlytics_platform_interface---v324)
 - [`firebase_remote_config` - `v2.0.5`](#firebase_remote_config---v205)
 - [`firebase_remote_config_web` - `v1.0.10`](#firebase_remote_config_web---v1010)
 - [`firebase_auth_web` - `v3.3.13`](#firebase_auth_web---v3313)
 - [`firebase_database_web` - `v0.2.0+11`](#firebase_database_web---v02011)
 - [`firebase_auth_platform_interface` - `v6.2.4`](#firebase_auth_platform_interface---v624)
 - [`firebase_remote_config_platform_interface` - `v1.1.4`](#firebase_remote_config_platform_interface---v114)
 - [`firebase_database` - `v9.0.12`](#firebase_database---v9012)
 - [`firebase_database_platform_interface` - `v0.2.1+4`](#firebase_database_platform_interface---v0214)
 - [`cloud_firestore` - `v3.1.13`](#cloud_firestore---v3113)
 - [`cloud_firestore_platform_interface` - `v5.5.4`](#cloud_firestore_platform_interface---v554)
 - [`cloud_firestore_web` - `v2.6.13`](#cloud_firestore_web---v2613)
 - [`firebase_app_installations_web` - `v0.1.0+11`](#firebase_app_installations_web---v01011)
 - [`firebase_app_installations` - `v0.1.0+11`](#firebase_app_installations---v01011)
 - [`firebase_analytics_platform_interface` - `v3.1.4`](#firebase_analytics_platform_interface---v314)
 - [`firebase_analytics_web` - `v0.4.0+11`](#firebase_analytics_web---v04011)
 - [`firebase_app_installations_platform_interface` - `v0.1.1+4`](#firebase_app_installations_platform_interface---v0114)
 - [`firebase_messaging` - `v11.2.14`](#firebase_messaging---v11214)
 - [`firebase_messaging_web` - `v2.2.12`](#firebase_messaging_web---v2212)
 - [`firebase_ml_model_downloader_platform_interface` - `v0.1.1+4`](#firebase_ml_model_downloader_platform_interface---v0114)
 - [`firebase_ml_model_downloader` - `v0.1.0+11`](#firebase_ml_model_downloader---v01011)
 - [`firebase_app_check_platform_interface` - `v0.0.4+4`](#firebase_app_check_platform_interface---v0044)
 - [`cloud_functions_web` - `v4.2.12`](#cloud_functions_web---v4212)
 - [`firebase_app_check` - `v0.0.6+10`](#firebase_app_check---v00610)
 - [`cloud_functions_platform_interface` - `v5.1.4`](#cloud_functions_platform_interface---v514)
 - [`cloud_functions` - `v3.2.13`](#cloud_functions---v3213)
 - [`firebase_app_check_web` - `v0.0.5+10`](#firebase_app_check_web---v00510)
 - [`firebase_storage_platform_interface` - `v4.1.4`](#firebase_storage_platform_interface---v414)
 - [`firebase_storage_web` - `v3.2.13`](#firebase_storage_web---v3213)
 - [`firebase_storage` - `v10.2.13`](#firebase_storage---v10213)
 - [`firebase_performance_platform_interface` - `v0.1.1+4`](#firebase_performance_platform_interface---v0114)
 - [`firebase_performance_web` - `v0.1.0+10`](#firebase_performance_web---v01010)
 - [`firebase_performance` - `v0.8.0+10`](#firebase_performance---v08010)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `firebase_crashlytics` - `v2.6.3`
 - `firebase_in_app_messaging_platform_interface` - `v0.2.1+4`
 - `firebase_in_app_messaging` - `v0.6.0+12`
 - `firebase_crashlytics_platform_interface` - `v3.2.4`
 - `firebase_remote_config` - `v2.0.5`
 - `firebase_remote_config_web` - `v1.0.10`
 - `firebase_auth_web` - `v3.3.13`
 - `firebase_database_web` - `v0.2.0+11`
 - `firebase_auth_platform_interface` - `v6.2.4`
 - `firebase_remote_config_platform_interface` - `v1.1.4`
 - `firebase_database` - `v9.0.12`
 - `firebase_database_platform_interface` - `v0.2.1+4`
 - `cloud_firestore` - `v3.1.13`
 - `cloud_firestore_platform_interface` - `v5.5.4`
 - `cloud_firestore_web` - `v2.6.13`
 - `firebase_app_installations_web` - `v0.1.0+11`
 - `firebase_app_installations` - `v0.1.0+11`
 - `firebase_analytics_platform_interface` - `v3.1.4`
 - `firebase_analytics_web` - `v0.4.0+11`
 - `firebase_app_installations_platform_interface` - `v0.1.1+4`
 - `firebase_messaging` - `v11.2.14`
 - `firebase_messaging_web` - `v2.2.12`
 - `firebase_ml_model_downloader_platform_interface` - `v0.1.1+4`
 - `firebase_ml_model_downloader` - `v0.1.0+11`
 - `firebase_app_check_platform_interface` - `v0.0.4+4`
 - `cloud_functions_web` - `v4.2.12`
 - `firebase_app_check` - `v0.0.6+10`
 - `cloud_functions_platform_interface` - `v5.1.4`
 - `cloud_functions` - `v3.2.13`
 - `firebase_app_check_web` - `v0.0.5+10`
 - `firebase_storage_platform_interface` - `v4.1.4`
 - `firebase_storage_web` - `v3.2.13`
 - `firebase_storage` - `v10.2.13`
 - `firebase_performance_platform_interface` - `v0.1.1+4`
 - `firebase_performance_web` - `v0.1.0+10`
 - `firebase_performance` - `v0.8.0+10`

---

#### `cloud_firestore_odm` - `v1.0.0-dev.13`

 - **FEAT**: upgrade analyzer, freezed_annotation and json_serializable dependencies (#8465). ([8a27ab21](https://github.com/firebase/flutterfire/commit/8a27ab21279d72998e80aa17b8ec39a9e4a08ec8))

#### `cloud_firestore_odm_generator` - `v1.0.0-dev.13`

 - **FEAT**: upgrade analyzer, freezed_annotation and json_serializable dependencies (#8465). ([8a27ab21](https://github.com/firebase/flutterfire/commit/8a27ab21279d72998e80aa17b8ec39a9e4a08ec8))

#### `firebase_analytics` - `v9.1.6`

 - **REFACTOR**: Update deployment target to `10.0` for Firebase Analytics podspec. (#8371). ([fe709da9](https://github.com/firebase/flutterfire/commit/fe709da998162a3b884070df6666690ae560d0d1))

#### `firebase_auth` - `v3.3.15`

 - **FIX**: Use iterator instead of enhanced for loop on android. (#8498). ([027c75a6](https://github.com/firebase/flutterfire/commit/027c75a60b39a40e6a3edc12edc51487cc954503))

#### `firebase_core` - `v1.15.0`

 - **FEAT**: bump Firebase Android SDK to `29.3.1` (#8494). ([17b9c289](https://github.com/firebase/flutterfire/commit/17b9c2894ee901afd2631664b01829cd4df1dd16))
 - **FEAT**: Update Firebase iOS SDK to `8.15.0` (#8454). ([faaf4496](https://github.com/firebase/flutterfire/commit/faaf449624ff4081cbbc0f241fec3134492cbdb3))

#### `firebase_dynamic_links` - `v4.2.0`

 - **REFACTOR**: Remove deprecated Tasks.call() API from android. (#8450). ([fdb24c8d](https://github.com/firebase/flutterfire/commit/fdb24c8d2cf4c51b20ffdb6c8898b7eced16aa64))
 - **FEAT**: `matchType` for pending Dynamic Link data for `iOS`. (#8464). ([d3dda125](https://github.com/firebase/flutterfire/commit/d3dda12563eb28e565c2c01d348183d558e25335))

#### `firebase_dynamic_links_platform_interface` - `v0.2.3`

 - **FEAT**: `matchType` for pending Dynamic Link data for `iOS`. (#8464). ([d3dda125](https://github.com/firebase/flutterfire/commit/d3dda12563eb28e565c2c01d348183d558e25335))

#### `firebase_messaging_platform_interface` - `v3.3.0`

 - **FEAT**: add `toMap()` method to `RemoteMessage` and its properties (#8453). ([047cccda](https://github.com/firebase/flutterfire/commit/047cccda6fe8e53c77e8e1f368e5f2c5d7d297e1))

#### `flutterfire_ui` - `v0.4.0+3`

 - **FIX**: Bump `twitter_login` version to fix Android build failure. (#8475). ([4a7f47ed](https://github.com/firebase/flutterfire/commit/4a7f47edbe9d421e385efbd2be05a01a24b22a69))


## 2022-04-13

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`firebase_core_web` - `v1.6.2`](#firebase_core_web---v162)
 - [`firebase_auth_web` - `v3.3.12`](#firebase_auth_web---v3312)
 - [`firebase_remote_config_web` - `v1.0.9`](#firebase_remote_config_web---v109)
 - [`firebase_database_web` - `v0.2.0+10`](#firebase_database_web---v02010)
 - [`cloud_firestore_web` - `v2.6.12`](#cloud_firestore_web---v2612)
 - [`firebase_app_installations_web` - `v0.1.0+10`](#firebase_app_installations_web---v01010)
 - [`firebase_messaging_web` - `v2.2.11`](#firebase_messaging_web---v2211)
 - [`firebase_core` - `v1.14.1`](#firebase_core---v1141)
 - [`firebase_analytics_web` - `v0.4.0+10`](#firebase_analytics_web---v04010)
 - [`firebase_app_check_web` - `v0.0.5+9`](#firebase_app_check_web---v0059)
 - [`cloud_functions_web` - `v4.2.11`](#cloud_functions_web---v4211)
 - [`firebase_storage_web` - `v3.2.12`](#firebase_storage_web---v3212)
 - [`firebase_performance_web` - `v0.1.0+9`](#firebase_performance_web---v0109)
 - [`firebase_auth` - `v3.3.14`](#firebase_auth---v3314)
 - [`firebase_remote_config` - `v2.0.4`](#firebase_remote_config---v204)
 - [`firebase_database` - `v9.0.11`](#firebase_database---v9011)
 - [`cloud_firestore` - `v3.1.12`](#cloud_firestore---v3112)
 - [`firebase_app_installations` - `v0.1.0+10`](#firebase_app_installations---v01010)
 - [`firebase_messaging` - `v11.2.13`](#firebase_messaging---v11213)
 - [`firebase_in_app_messaging` - `v0.6.0+11`](#firebase_in_app_messaging---v06011)
 - [`firebase_crashlytics` - `v2.6.2`](#firebase_crashlytics---v262)
 - [`firebase_crashlytics_platform_interface` - `v3.2.3`](#firebase_crashlytics_platform_interface---v323)
 - [`firebase_in_app_messaging_platform_interface` - `v0.2.1+3`](#firebase_in_app_messaging_platform_interface---v0213)
 - [`firebase_auth_platform_interface` - `v6.2.3`](#firebase_auth_platform_interface---v623)
 - [`firebase_database_platform_interface` - `v0.2.1+3`](#firebase_database_platform_interface---v0213)
 - [`firebase_remote_config_platform_interface` - `v1.1.3`](#firebase_remote_config_platform_interface---v113)
 - [`firebase_dynamic_links_platform_interface` - `v0.2.2+3`](#firebase_dynamic_links_platform_interface---v0223)
 - [`firebase_dynamic_links` - `v4.1.3`](#firebase_dynamic_links---v413)
 - [`cloud_firestore_platform_interface` - `v5.5.3`](#cloud_firestore_platform_interface---v553)
 - [`firebase_app_installations_platform_interface` - `v0.1.1+3`](#firebase_app_installations_platform_interface---v0113)
 - [`firebase_messaging_platform_interface` - `v3.2.3`](#firebase_messaging_platform_interface---v323)
 - [`firebase_analytics_platform_interface` - `v3.1.3`](#firebase_analytics_platform_interface---v313)
 - [`firebase_analytics` - `v9.1.5`](#firebase_analytics---v915)
 - [`firebase_ml_model_downloader` - `v0.1.0+10`](#firebase_ml_model_downloader---v01010)
 - [`firebase_ml_model_downloader_platform_interface` - `v0.1.1+3`](#firebase_ml_model_downloader_platform_interface---v0113)
 - [`flutterfire_ui` - `v0.4.0+2`](#flutterfire_ui---v0402)
 - [`firebase_app_check_platform_interface` - `v0.0.4+3`](#firebase_app_check_platform_interface---v0043)
 - [`cloud_functions` - `v3.2.12`](#cloud_functions---v3212)
 - [`firebase_app_check` - `v0.0.6+9`](#firebase_app_check---v0069)
 - [`cloud_functions_platform_interface` - `v5.1.3`](#cloud_functions_platform_interface---v513)
 - [`firebase_storage_platform_interface` - `v4.1.3`](#firebase_storage_platform_interface---v413)
 - [`firebase_storage` - `v10.2.12`](#firebase_storage---v10212)
 - [`firebase_performance_platform_interface` - `v0.1.1+3`](#firebase_performance_platform_interface---v0113)
 - [`firebase_performance` - `v0.8.0+9`](#firebase_performance---v0809)
 - [`cloud_firestore_odm` - `v1.0.0-dev.12`](#cloud_firestore_odm---v100-dev12)
 - [`cloud_firestore_odm_generator` - `v1.0.0-dev.12`](#cloud_firestore_odm_generator---v100-dev12)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `firebase_auth_web` - `v3.3.12`
 - `firebase_remote_config_web` - `v1.0.9`
 - `firebase_database_web` - `v0.2.0+10`
 - `cloud_firestore_web` - `v2.6.12`
 - `firebase_app_installations_web` - `v0.1.0+10`
 - `firebase_messaging_web` - `v2.2.11`
 - `firebase_core` - `v1.14.1`
 - `firebase_analytics_web` - `v0.4.0+10`
 - `firebase_app_check_web` - `v0.0.5+9`
 - `cloud_functions_web` - `v4.2.11`
 - `firebase_storage_web` - `v3.2.12`
 - `firebase_performance_web` - `v0.1.0+9`
 - `firebase_auth` - `v3.3.14`
 - `firebase_remote_config` - `v2.0.4`
 - `firebase_database` - `v9.0.11`
 - `cloud_firestore` - `v3.1.12`
 - `firebase_app_installations` - `v0.1.0+10`
 - `firebase_messaging` - `v11.2.13`
 - `firebase_in_app_messaging` - `v0.6.0+11`
 - `firebase_crashlytics` - `v2.6.2`
 - `firebase_crashlytics_platform_interface` - `v3.2.3`
 - `firebase_in_app_messaging_platform_interface` - `v0.2.1+3`
 - `firebase_auth_platform_interface` - `v6.2.3`
 - `firebase_database_platform_interface` - `v0.2.1+3`
 - `firebase_remote_config_platform_interface` - `v1.1.3`
 - `firebase_dynamic_links_platform_interface` - `v0.2.2+3`
 - `firebase_dynamic_links` - `v4.1.3`
 - `cloud_firestore_platform_interface` - `v5.5.3`
 - `firebase_app_installations_platform_interface` - `v0.1.1+3`
 - `firebase_messaging_platform_interface` - `v3.2.3`
 - `firebase_analytics_platform_interface` - `v3.1.3`
 - `firebase_analytics` - `v9.1.5`
 - `firebase_ml_model_downloader` - `v0.1.0+10`
 - `firebase_ml_model_downloader_platform_interface` - `v0.1.1+3`
 - `flutterfire_ui` - `v0.4.0+2`
 - `firebase_app_check_platform_interface` - `v0.0.4+3`
 - `cloud_functions` - `v3.2.12`
 - `firebase_app_check` - `v0.0.6+9`
 - `cloud_functions_platform_interface` - `v5.1.3`
 - `firebase_storage_platform_interface` - `v4.1.3`
 - `firebase_storage` - `v10.2.12`
 - `firebase_performance_platform_interface` - `v0.1.1+3`
 - `firebase_performance` - `v0.8.0+9`
 - `cloud_firestore_odm` - `v1.0.0-dev.12`
 - `cloud_firestore_odm_generator` - `v1.0.0-dev.12`

---

#### `firebase_core_web` - `v1.6.2`

 - **DOCS**: Fix typo in "firebase_core_web.dart" documentation. ([658c1db7](https://github.com/firebase/flutterfire/commit/658c1db71cc47b3eddec3a1f33d5d55d1a6ff98a))


## 2022-04-07

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`firebase_analytics` - `v9.1.4`](#firebase_analytics---v914)
 - [`firebase_auth_web` - `v3.3.11`](#firebase_auth_web---v3311)
 - [`firebase_database_web` - `v0.2.0+9`](#firebase_database_web---v0209)
 - [`firebase_storage` - `v10.2.11`](#firebase_storage---v10211)
 - [`flutterfire_ui` - `v0.4.0+1`](#flutterfire_ui---v0401)
 - [`firebase_auth` - `v3.3.13`](#firebase_auth---v3313)
 - [`firebase_database` - `v9.0.10`](#firebase_database---v9010)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `firebase_auth` - `v3.3.13`
 - `firebase_database` - `v9.0.10`

---

#### `firebase_analytics` - `v9.1.4`

 - **FIX**: Send default parameters for iOS when using `setDefaultEventParameters()` API. (#8402). ([7d3e5ba6](https://github.com/firebase/flutterfire/commit/7d3e5ba6e4ee0bff178c5cfb73d34cdd3a7064e0))

#### `firebase_auth_web` - `v3.3.11`

 - **FIX**: Allow `rawNonce` to be passed through on web via the `OAuthCredential`. (#8410). ([0df32f61](https://github.com/firebase/flutterfire/commit/0df32f6106ca41cdb95c36c7816e6487124937d4))

#### `firebase_database_web` - `v0.2.0+9`

 - **FIX**: Remove sync as `true` on Stream broadcast for web platform. (#8420). ([4336e047](https://github.com/firebase/flutterfire/commit/4336e0478a927385e676b069f354bd3cc2f932ab))

#### `firebase_storage` - `v10.2.11`

 - **FIX**: Fix `UploadTask.cancel()` so that it completes when called. (#8417). ([19ee62c3](https://github.com/firebase/flutterfire/commit/19ee62c33f34278dac082c11bf7574785e60abb5))

#### `flutterfire_ui` - `v0.4.0+1`

 - **FIX**: filter out whitespaces in email with input formatter (#8393). ([1da9dc15](https://github.com/firebase/flutterfire/commit/1da9dc1539367641a43df053c243fe262e087bd2))
 - **FIX**: fix phone linking on web (#8395). ([b8ac0a20](https://github.com/firebase/flutterfire/commit/b8ac0a202958864f793791877e556624f9b7c487))


## 2022-04-05

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`firebase_crashlytics` - `v2.6.1`](#firebase_crashlytics---v261)

---

#### `firebase_crashlytics` - `v2.6.1`

 - **FIX**: Exit the add crashlytics upload-symbols script if the required json isn't present. ([94077929](https://github.com/firebase/flutterfire/commit/940779290a3039181a92567fe8492a720af899e1))


## 2022-03-31

### Changes

---

Packages with breaking changes:

 - [`flutterfire_ui` - `v0.4.0`](#flutterfire_ui---v040)

Packages with other changes:

 - [`cloud_firestore` - `v3.1.11`](#cloud_firestore---v3111)
 - [`cloud_firestore_platform_interface` - `v5.5.2`](#cloud_firestore_platform_interface---v552)
 - [`firebase_auth_web` - `v3.3.10`](#firebase_auth_web---v3310)
 - [`firebase_core` - `v1.14.0`](#firebase_core---v1140)
 - [`firebase_crashlytics` - `v2.6.0`](#firebase_crashlytics---v260)
 - [`firebase_dynamic_links` - `v4.1.2`](#firebase_dynamic_links---v412)
 - [`cloud_firestore_odm` - `v1.0.0-dev.11`](#cloud_firestore_odm---v100-dev11)
 - [`cloud_firestore_odm_generator` - `v1.0.0-dev.11`](#cloud_firestore_odm_generator---v100-dev11)
 - [`cloud_firestore_web` - `v2.6.11`](#cloud_firestore_web---v2611)
 - [`firebase_auth` - `v3.3.12`](#firebase_auth---v3312)
 - [`firebase_in_app_messaging_platform_interface` - `v0.2.1+2`](#firebase_in_app_messaging_platform_interface---v0212)
 - [`firebase_in_app_messaging` - `v0.6.0+10`](#firebase_in_app_messaging---v06010)
 - [`firebase_crashlytics_platform_interface` - `v3.2.2`](#firebase_crashlytics_platform_interface---v322)
 - [`firebase_auth_platform_interface` - `v6.2.2`](#firebase_auth_platform_interface---v622)
 - [`firebase_remote_config` - `v2.0.3`](#firebase_remote_config---v203)
 - [`firebase_remote_config_web` - `v1.0.8`](#firebase_remote_config_web---v108)
 - [`firebase_database_web` - `v0.2.0+8`](#firebase_database_web---v0208)
 - [`firebase_remote_config_platform_interface` - `v1.1.2`](#firebase_remote_config_platform_interface---v112)
 - [`firebase_database` - `v9.0.9`](#firebase_database---v909)
 - [`firebase_database_platform_interface` - `v0.2.1+2`](#firebase_database_platform_interface---v0212)
 - [`firebase_dynamic_links_platform_interface` - `v0.2.2+2`](#firebase_dynamic_links_platform_interface---v0222)
 - [`firebase_app_installations_web` - `v0.1.0+9`](#firebase_app_installations_web---v0109)
 - [`firebase_app_installations` - `v0.1.0+9`](#firebase_app_installations---v0109)
 - [`firebase_app_installations_platform_interface` - `v0.1.1+2`](#firebase_app_installations_platform_interface---v0112)
 - [`firebase_messaging_web` - `v2.2.10`](#firebase_messaging_web---v2210)
 - [`firebase_messaging` - `v11.2.12`](#firebase_messaging---v11212)
 - [`firebase_messaging_platform_interface` - `v3.2.2`](#firebase_messaging_platform_interface---v322)
 - [`firebase_analytics_platform_interface` - `v3.1.2`](#firebase_analytics_platform_interface---v312)
 - [`firebase_analytics` - `v9.1.3`](#firebase_analytics---v913)
 - [`firebase_analytics_web` - `v0.4.0+9`](#firebase_analytics_web---v0409)
 - [`firebase_ml_model_downloader` - `v0.1.0+9`](#firebase_ml_model_downloader---v0109)
 - [`firebase_ml_model_downloader_platform_interface` - `v0.1.1+2`](#firebase_ml_model_downloader_platform_interface---v0112)
 - [`firebase_app_check_platform_interface` - `v0.0.4+2`](#firebase_app_check_platform_interface---v0042)
 - [`firebase_app_check` - `v0.0.6+8`](#firebase_app_check---v0068)
 - [`cloud_functions_web` - `v4.2.10`](#cloud_functions_web---v4210)
 - [`firebase_app_check_web` - `v0.0.5+8`](#firebase_app_check_web---v0058)
 - [`cloud_functions` - `v3.2.11`](#cloud_functions---v3211)
 - [`cloud_functions_platform_interface` - `v5.1.2`](#cloud_functions_platform_interface---v512)
 - [`firebase_storage_web` - `v3.2.11`](#firebase_storage_web---v3211)
 - [`firebase_storage_platform_interface` - `v4.1.2`](#firebase_storage_platform_interface---v412)
 - [`firebase_storage` - `v10.2.10`](#firebase_storage---v10210)
 - [`firebase_performance_web` - `v0.1.0+8`](#firebase_performance_web---v0108)
 - [`firebase_performance_platform_interface` - `v0.1.1+2`](#firebase_performance_platform_interface---v0112)
 - [`firebase_performance` - `v0.8.0+8`](#firebase_performance---v0808)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `cloud_firestore_odm` - `v1.0.0-dev.11`
 - `cloud_firestore_odm_generator` - `v1.0.0-dev.11`
 - `cloud_firestore_web` - `v2.6.11`
 - `firebase_auth` - `v3.3.12`
 - `firebase_in_app_messaging_platform_interface` - `v0.2.1+2`
 - `firebase_in_app_messaging` - `v0.6.0+10`
 - `firebase_crashlytics_platform_interface` - `v3.2.2`
 - `firebase_auth_platform_interface` - `v6.2.2`
 - `firebase_remote_config` - `v2.0.3`
 - `firebase_remote_config_web` - `v1.0.8`
 - `firebase_database_web` - `v0.2.0+8`
 - `firebase_remote_config_platform_interface` - `v1.1.2`
 - `firebase_database` - `v9.0.9`
 - `firebase_database_platform_interface` - `v0.2.1+2`
 - `firebase_dynamic_links_platform_interface` - `v0.2.2+2`
 - `firebase_app_installations_web` - `v0.1.0+9`
 - `firebase_app_installations` - `v0.1.0+9`
 - `firebase_app_installations_platform_interface` - `v0.1.1+2`
 - `firebase_messaging_web` - `v2.2.10`
 - `firebase_messaging` - `v11.2.12`
 - `firebase_messaging_platform_interface` - `v3.2.2`
 - `firebase_analytics_platform_interface` - `v3.1.2`
 - `firebase_analytics` - `v9.1.3`
 - `firebase_analytics_web` - `v0.4.0+9`
 - `firebase_ml_model_downloader` - `v0.1.0+9`
 - `firebase_ml_model_downloader_platform_interface` - `v0.1.1+2`
 - `firebase_app_check_platform_interface` - `v0.0.4+2`
 - `firebase_app_check` - `v0.0.6+8`
 - `cloud_functions_web` - `v4.2.10`
 - `firebase_app_check_web` - `v0.0.5+8`
 - `cloud_functions` - `v3.2.11`
 - `cloud_functions_platform_interface` - `v5.1.2`
 - `firebase_storage_web` - `v3.2.11`
 - `firebase_storage_platform_interface` - `v4.1.2`
 - `firebase_storage` - `v10.2.10`
 - `firebase_performance_web` - `v0.1.0+8`
 - `firebase_performance_platform_interface` - `v0.1.1+2`
 - `firebase_performance` - `v0.8.0+8`

---

#### `flutterfire_ui` - `v0.4.0`

 - **REFACTOR**: refactor platform specific widget styling (#8333). ([ecbff15c](https://github.com/firebase/flutterfire/commit/ecbff15cf657a1d451db39bb8a5b4f3419780228))
 - **FIX**: respect autocorrect property on `UniversalTextFormField` (#8367). ([ad942c34](https://github.com/firebase/flutterfire/commit/ad942c349c3232f1946575fdab2b8b27e1c14215))
 - **FIX**: trim email before submitting (#8369). ([4f9b8855](https://github.com/firebase/flutterfire/commit/4f9b8855504d5ae85d5904f4663fa93fa871e32a))
 - **FIX**: allow passing oauth scopes for google sign in (#8368). ([7edbf5e6](https://github.com/firebase/flutterfire/commit/7edbf5e692499feb7b3c1b29dab67479917df21f))
 - **FIX**: Avoid layout jumps when editing user name. (#8334). ([1937f278](https://github.com/firebase/flutterfire/commit/1937f27817acc59dedd85a6d1e0624f49685ef5e))
 - **FIX**: fix sign out issue on desktop and web (#8331). ([f1dae735](https://github.com/firebase/flutterfire/commit/f1dae735483bf293c4b18a8ff7c3ab6ca3cbe6e7))
 - **FIX**: Fix Flutter Cupertino button color bug. (#8315). ([47dc6d09](https://github.com/firebase/flutterfire/commit/47dc6d09112db8d1398908895b387795722eaaba))
 - **FEAT**: Allow setting `resizeToAvoidBottomInset` from LoginScreen and set as default `false` for backwards compatibility. (#8365). ([3e884f2f](https://github.com/firebase/flutterfire/commit/3e884f2f7cb498c6dff23ff6ac2bd9a25a73034d))
 - **FEAT**: Add Japanese localization language support. (#8110). ([c9c7f828](https://github.com/firebase/flutterfire/commit/c9c7f8281fbfb2cd2872eb1b71fbd5e46c8002d8))
 - **BREAKING** **FEAT**: add email verification and allow to unlink social providers from profile screen (#8358). ([89f97047](https://github.com/firebase/flutterfire/commit/89f97047e34d5023f2c41312767f626cb662702f))

#### `cloud_firestore` - `v3.1.11`

 - **REFACTOR**: recreate ios, android, web and macOS folders for example app (#8255). ([cdae0613](https://github.com/firebase/flutterfire/commit/cdae0613a359da41013721f601c20169807d214f))
 - **DOCS**: Fix method name typo in code documentation (#8291). ([7b4e06db](https://github.com/firebase/flutterfire/commit/7b4e06db305ff9f785a1bfcf1888fec1a53970c4))

#### `cloud_firestore_platform_interface` - `v5.5.2`

 - **DOCS**: Fix method name typo in code documentation (#8291). ([7b4e06db](https://github.com/firebase/flutterfire/commit/7b4e06db305ff9f785a1bfcf1888fec1a53970c4))

#### `firebase_auth_web` - `v3.3.10`

 - **FIX**: Check if `UserMetadata` properties are `null` before parsing. (#8313). ([cac41fb9](https://github.com/firebase/flutterfire/commit/cac41fb9ddd5462b57f9d17615f387478f10d3dc))

#### `firebase_core` - `v1.14.0`

 - **FEAT**: Bump Firebase iOS SDK to `8.14.0`. (#8370). ([41bb9800](https://github.com/firebase/flutterfire/commit/41bb98004327013f90c93709513c419d04382475))
 - **FEAT**: bump Firebase Android SDK to `29.3.0` (#8283). ([a6c646a0](https://github.com/firebase/flutterfire/commit/a6c646a0d23600e5e4ae6d40ca4b23c7e73fc257))
 - **DOCS**: Update inline code documentation for initializing Firebase app. (#8329). ([19727798](https://github.com/firebase/flutterfire/commit/19727798a8dcfde103665eb8209b714e49327a11))

#### `firebase_crashlytics` - `v2.6.0`

 - **FEAT**: add automatic Crashlytics symbol uploads for iOS & macOS apps (#8157). ([c4a3eaa7](https://github.com/firebase/flutterfire/commit/c4a3eaa7200d924f9ec71370dd3c875813804935))

#### `firebase_dynamic_links` - `v4.1.2`

 - **REFACTOR**: recreate ios, android, web and macOS folders for example app (#8255). ([cdae0613](https://github.com/firebase/flutterfire/commit/cdae0613a359da41013721f601c20169807d214f))


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

 - **FIX**: Update APN token once auth plugin has been initialized on `iOS`. (#8201). ([ab6239dd](https://github.com/firebase/flutterfire/commit/ab6239ddf5cb14211b76bced04ec52203919a57a))

#### `firebase_dynamic_links_platform_interface` - `v0.2.2+1`

 - **FIX**: Properly type cast utmParameters coming from native side. (#8280). ([22bbd807](https://github.com/firebase/flutterfire/commit/22bbd807d2b3c3f9d9cc8ba817ccb4da931ae887))

#### `firebase_messaging` - `v11.2.11`

 - **FIX**: Ensure `onMessage` callback is consistently called on `iOS` platform. (#8202). ([54f5555e](https://github.com/firebase/flutterfire/commit/54f5555edbedc553df30d7e32747e3b305fbe643))


## 2022-03-10

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`firebase_messaging` - `v11.2.10`](#firebase_messaging---v11210)

---

#### `firebase_messaging` - `v11.2.10`

 - **FIX**: Update notification key to `NSApplicationLaunchUserNotificationKey` for macOS. (#8251). ([46b54ccd](https://github.com/firebase/flutterfire/commit/46b54ccd4aee61654e36396b86ed373939569d00))


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

 - **FIX**: Allow raw data arguments to be passed as data to Cloud Function for `Android` & `iOS`. (#7994). ([8288b811](https://github.com/firebase/flutterfire/commit/8288b811f2b82df263a092428905960960e537c6))

#### `firebase_auth` - `v3.3.10`

 - **FIX**: return correct error code for linkWithCredential `provider-already-linked` on Android (#8245). ([ae090719](https://github.com/firebase/flutterfire/commit/ae090719ebbb0873cf227f76004feeae9a7d0580))
 - **FIX**: Fixed bug that sets email to `nil` on `iOS` when the `User` has no provider. (#8209). ([fb646438](https://github.com/firebase/flutterfire/commit/fb646438f219b0f0f7c6a8c52e2b9daa4afc833e))

#### `firebase_dynamic_links` - `v4.1.0`

 - **FIX**: pass through `utmParameters` on `iOS` and make property on `PendingDynamicLinkData`. (#8232). ([32d06e79](https://github.com/firebase/flutterfire/commit/32d06e793b4fc1bc1dad9b9071f94b28c5d477ca))
 - **FEAT**: add additional `longDynamicLink` parameter for creating a short Dynamic Link enabling additional parameters to be appended such as "ofl". (#7796). ([433a08ea](https://github.com/firebase/flutterfire/commit/433a08eaacfaabb109a0185a5e494d87f9334d75))

#### `firebase_dynamic_links_platform_interface` - `v0.2.2`

 - **FIX**: pass through `utmParameters` on `iOS` and make property on `PendingDynamicLinkData`. (#8232). ([32d06e79](https://github.com/firebase/flutterfire/commit/32d06e793b4fc1bc1dad9b9071f94b28c5d477ca))
 - **FEAT**: add additional `longDynamicLink` parameter for creating a short Dynamic Link enabling additional parameters to be appended such as "ofl". (#7796). ([433a08ea](https://github.com/firebase/flutterfire/commit/433a08eaacfaabb109a0185a5e494d87f9334d75))

#### `firebase_messaging` - `v11.2.9`

 - **FIX**: `getInitialMessage` returns notification once & only if pressed for `iOS`. (#7634). ([85739b4c](https://github.com/firebase/flutterfire/commit/85739b4cc2f75c6f7017de0e69160fa07477eb1e))

#### `flutterfire_ui` - `v0.3.6`

 - **FEAT**: Add German localization language support (#8195). ([9976d9d6](https://github.com/firebase/flutterfire/commit/9976d9d66b870143227b08af068da3bc2efc5411))


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

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `cloud_firestore_odm` - `v1.0.0-dev.10`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `cloud_firestore_odm_generator` - `v1.0.0-dev.10`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `cloud_firestore_platform_interface` - `v5.5.1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `cloud_firestore_web` - `v2.6.10`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `cloud_functions` - `v3.2.9`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `cloud_functions_platform_interface` - `v5.1.1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `cloud_functions_web` - `v4.2.9`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_analytics` - `v9.1.2`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_analytics_platform_interface` - `v3.1.1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_analytics_web` - `v0.4.0+8`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_app_check` - `v0.0.6+7`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_app_check_platform_interface` - `v0.0.4+1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_app_check_web` - `v0.0.5+7`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_app_installations` - `v0.1.0+8`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_app_installations_platform_interface` - `v0.1.1+1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_app_installations_web` - `v0.1.0+8`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_auth` - `v3.3.9`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_auth_platform_interface` - `v6.2.1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_auth_web` - `v3.3.9`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_core` - `v1.13.1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_core_platform_interface` - `v4.2.5`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_core_web` - `v1.6.1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_crashlytics` - `v2.5.3`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_crashlytics_platform_interface` - `v3.2.1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_database` - `v9.0.8`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_database_platform_interface` - `v0.2.1+1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_database_web` - `v0.2.0+7`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_dynamic_links` - `v4.0.8`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_dynamic_links_platform_interface` - `v0.2.1+1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_in_app_messaging` - `v0.6.0+9`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_in_app_messaging_platform_interface` - `v0.2.1+1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_messaging` - `v11.2.8`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_messaging_platform_interface` - `v3.2.1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_messaging_web` - `v2.2.9`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_ml_model_downloader` - `v0.1.0+8`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_ml_model_downloader_platform_interface` - `v0.1.1+1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_performance` - `v0.8.0+7`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_performance_platform_interface` - `v0.1.1+1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_performance_web` - `v0.1.0+7`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_remote_config` - `v2.0.2`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_remote_config_platform_interface` - `v1.1.1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_remote_config_web` - `v1.0.7`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_storage` - `v10.2.9`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_storage_platform_interface` - `v4.1.1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `firebase_storage_web` - `v3.2.10`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))

#### `flutterfire_ui` - `v0.3.5+1`

 - **FIX**: update all Dart SDK version constraints to Dart >= 2.16.0 (#8184). ([df4a5bab](https://github.com/firebase/flutterfire/commit/df4a5bab3c029399b4f257a5dd658d302efe3908))


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

 - **FIX**: Use descending in orderBy* (#8159). ([0b7b8811](https://github.com/firebase/flutterfire/commit/0b7b88117ac65a0ab164ffcaa0ca7fa69633fcb2))

#### `cloud_firestore_platform_interface` - `v5.5.0`

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/firebase/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

#### `cloud_functions_platform_interface` - `v5.1.0`

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/firebase/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

#### `firebase_analytics` - `v9.1.1`

 - **DOCS**: code comment typo - `logAdImpression` mentions wrong event (#8180). ([960a75a7](https://github.com/firebase/flutterfire/commit/960a75a77dc8c575e7f8f9c4350ad564a3814eb8))

#### `firebase_analytics_platform_interface` - `v3.1.0`

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/firebase/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

#### `firebase_app_check_platform_interface` - `v0.0.4`

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/firebase/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

#### `firebase_app_installations_platform_interface` - `v0.1.1`

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/firebase/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

#### `firebase_auth_platform_interface` - `v6.2.0`

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/firebase/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

#### `firebase_core` - `v1.13.0`

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/firebase/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

#### `firebase_core_web` - `v1.6.0`

 - **FEAT**: Bump Firebase Web SDK version to 8.10.1 (CVE-2022-0235) for security patch purposes. (#8162). ([7624f777](https://github.com/firebase/flutterfire/commit/7624f7779f4a49f2353f3f593b31be9139197028))

#### `firebase_crashlytics_platform_interface` - `v3.2.0`

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/firebase/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

#### `firebase_database_platform_interface` - `v0.2.1`

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/firebase/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

#### `firebase_dynamic_links_platform_interface` - `v0.2.1`

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/firebase/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

#### `firebase_in_app_messaging_platform_interface` - `v0.2.1`

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/firebase/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

#### `firebase_messaging` - `v11.2.7`

 - **FIX**: Stream new token via onTokenRefresh when getToken invoked for iOS. (#8166). ([28b396b8](https://github.com/firebase/flutterfire/commit/28b396b84e019a5247e70d0abeb1ba24bdff4bcb))

#### `firebase_messaging_platform_interface` - `v3.2.0`

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/firebase/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

#### `firebase_ml_model_downloader_platform_interface` - `v0.1.1`

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/firebase/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

#### `firebase_performance` - `v0.8.0+6`

 - **FIX**: Fix firebase_performance not recording response payload size on Android. (#8154). ([46d8bc0f](https://github.com/firebase/flutterfire/commit/46d8bc0f205f24b1e160333ddb76200543f48c89))

#### `firebase_performance_platform_interface` - `v0.1.1`

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/firebase/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

#### `firebase_remote_config` - `v2.0.1`

 - **FIX**: add missing `default_package` entry for web in `pubspec.yaml` (#8139). ([5e6b570f](https://github.com/firebase/flutterfire/commit/5e6b570f8445b0bd2eac8b112a2a6b35ff69b7b6))

#### `firebase_remote_config_platform_interface` - `v1.1.0`

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/firebase/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

#### `firebase_storage_platform_interface` - `v4.1.0`

 - **FEAT**: refactor error handling to preserve stack traces on platform exceptions (#8156). ([6ac77d99](https://github.com/firebase/flutterfire/commit/6ac77d99042de2a1950f89b35972e3ee1116dc9f))

#### `flutterfire_ui` - `v0.3.5`

 - **FIX**: Upgrade `desktop_webview_auth` - v`0.0.5` (#8164). ([123fa6b1](https://github.com/firebase/flutterfire/commit/123fa6b132183a4d6886c8be0595104752724532))
 - **FIX**: Upgrade `desktop_webview_auth` package causing a problem on macOS. (#8151). ([da4a1c5e](https://github.com/firebase/flutterfire/commit/da4a1c5e074cb5af71983a3ae49c4838402b726f))
 - **FEAT**: Add support for configuring authentication providers globally (additionally fixes #7801) (#8120). ([ebde7d27](https://github.com/firebase/flutterfire/commit/ebde7d27938d7a36a67973df4b33c21bbd7dea1a))
 - **FEAT**: Add Hindi localization language support (#7778). ([b584ce0f](https://github.com/firebase/flutterfire/commit/b584ce0f254dcb195f9a31f279fb3871d01182c1))
 - **FEAT**: Add Turkish language localization support. (#7790). ([c47f6075](https://github.com/firebase/flutterfire/commit/c47f60757ccbfcee1eaa5d7ed6ee01258f3b9d4f))
 - **FEAT**: Add Bahasa Indonesia localization language support (#7709). ([be0eb27f](https://github.com/firebase/flutterfire/commit/be0eb27f4f4d85a4e4a2468768c166a701325a8c))
 - **FEAT**: Enhance the oauth provider button widget by showing error text underneath. (#8032). ([2b47f5a1](https://github.com/firebase/flutterfire/commit/2b47f5a12747e3437dfc42d331684e798372beaf))


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

 - **DOCS**: Update code snippets by removing incorrect forward slash for `@Collection` annotations. (#8044). ([292f20c6](https://github.com/firebase/flutterfire/commit/292f20c61c0a479e5effcbf45a07f7fb782ba23e))

#### `cloud_firestore_platform_interface` - `v5.4.13`

 - **FIX**: Export enum `LoadBundleTaskState` from Platform Interface package. (#8027). ([7fa461e4](https://github.com/firebase/flutterfire/commit/7fa461e4476db3ac255877db93b6ccf493d0e1cf))

#### `firebase_auth` - `v3.3.7`

 - **DOCS**: Update documentation for `currentUser` property to make expectations clearer. (#7843). ([59bb47c2](https://github.com/firebase/flutterfire/commit/59bb47c2490fbd641a1fcc26f2f888e8f4f02671))

#### `firebase_dynamic_links` - `v4.0.6`

 - **FIX**: Ensure Dynamic link is retrieved from the Intent just once for `getInitialLink()` on Android as per the documentation. (#7743). ([67cc6647](https://github.com/firebase/flutterfire/commit/67cc66471046822463f326c05e732313dbaa9560))

#### `flutterfire_ui` - `v0.3.4`

 - **FEAT**: Add Italian localization language support. (#7823). ([c3a1a839](https://github.com/firebase/flutterfire/commit/c3a1a839a3963a75cc17e931a3eee6e091df40ac))


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
