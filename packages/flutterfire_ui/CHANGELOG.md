## 0.3.1

 - **FIX**: fix `ResponsivePage` overflow issue (#7792). ([4c633737](https://github.com/FirebaseExtended/flutterfire/commit/4c633737926f114ef32a409a1b0df6e262ba4816))
 - **FIX**: export DifferentSignInMethodsFound auth state and make sure to add it to the list of provided actions (#7789). ([0ebc382f](https://github.com/FirebaseExtended/flutterfire/commit/0ebc382f18039660d0d5a52c596155a58e201820))
 - **FIX**: validate email with the library instead of the RegExp (#7772). ([b271b7fc](https://github.com/FirebaseExtended/flutterfire/commit/b271b7fc8aa648d436041d0c6092a7de4b7f48d0))
 - **FIX**: not working onTap in OAuthProviderButtonWidget (#7641). ([d3b81eab](https://github.com/FirebaseExtended/flutterfire/commit/d3b81eabf9a2a9d10133a44d23a48997c776764f))
 - **FIX**: pass auth down to LoginView (#7645). ([e8926702](https://github.com/FirebaseExtended/flutterfire/commit/e8926702674cc41e019b3f5277683446b4106a31))
 - **FEAT**: add Spanish localization support (#7716). ([4e8931c8](https://github.com/FirebaseExtended/flutterfire/commit/4e8931c8b68290f3f9f16fceb5d345f34d4183b6))
 - **FEAT**: add French localization support (#7797). ([a1837a28](https://github.com/FirebaseExtended/flutterfire/commit/a1837a283d16d1e0d15a1f43ae2ead2b93470e64))
 - **FEAT**: add Arabic localization support (#7771). ([9e2959ec](https://github.com/FirebaseExtended/flutterfire/commit/9e2959ec04710b97a7f9d910a9ecd9c3aa879e13))
 - **DOCS**: update repository and homepage url (#7781). ([5034d699](https://github.com/FirebaseExtended/flutterfire/commit/5034d69926cb5da2a7da1a690021f92762188d03))
 - **DOCS**: add missing providerConfigs in example (#7724). ([8649f83d](https://github.com/FirebaseExtended/flutterfire/commit/8649f83dd38e8bce95fffd66870747ee0f70776f))

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
