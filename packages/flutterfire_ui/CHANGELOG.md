## 0.3.0

> Note: This release has breaking changes.

 - **FIX**: add missing export for `ProviderConfiguration` (#7585). ([050ed837](https://github.com/FirebaseExtended/flutterfire/commit/050ed837884a8945b31f60098eba7a0eb500a3d2))
 - **FIX**: some OAuth providers now work on macOS & web (#7576). ([a4315731](https://github.com/FirebaseExtended/flutterfire/commit/a43157316787edcdefb10f9534800692b76e92c3))
 - **FIX**: fix various typos in i10n text (#7624). ([504f7056](https://github.com/FirebaseExtended/flutterfire/commit/504f7056f74e4a7bb7800ed45e10910a373e9d29))
 - **BREAKING** **FEAT**: update all dependencies to use latest releases (#7549). ([051ff77b](https://github.com/FirebaseExtended/flutterfire/commit/051ff77b7e95c376dc2c5014877dd0a5a7856de8))
   - Note this has no breaking public API changes, however if you additionally also depend on some of the same dependencies in your app, e.g. `flutter_svg` then you may need to update your versions of these packages as well in your app `pubspec.yaml` to 
   avoid version resolution issues when running `pub get`.

## 0.2.0+2

 - Update a dependency to the latest release.

## 0.2.0+1

 - Update a dependency to the latest release.

## 0.2.0

> Note: This release has breaking changes.

 - **FIX**: fix issue with web and phone authentication (#7506).
 - **DOCS**: add readme documentation (#7508).
 - **DOCS**: Fix typos and remove unused imports (#7504).
 - **BREAKING** **FIX**: rename `QueryBuilderSnapshot` ->  `FirebaseQueryBuilderSnapshot` plus internal improvements and additional documentation (#7503).

## 0.1.0+1

 - **FIX**: email link sign in and add additional documentation (#7493).

## 0.1.0

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 0.1.0-dev.5

 - Update a dependency to the latest release.

## 0.1.0-dev.4

 - Bump "flutterfire_ui" to `0.1.0-dev.4`.

## 0.1.0-dev.3

 - Bump "flutterfire_ui" to `0.1.0-dev.3`.

## 0.1.0-dev.2

 - Bump "flutterfire_ui" to `0.1.0-dev.2`.

## 0.1.0-dev.1

 - Bump "flutterfire_ui" to `0.1.0-dev.1`.
