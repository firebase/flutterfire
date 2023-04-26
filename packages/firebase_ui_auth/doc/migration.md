# FlutterFireUI ➡️ FirebaseUI migration guide

To migrate from `flutterfire_ui` package to `firebase_ui_*` family, you need to do the following:

## Updating dependencies

For Firebase Auth widgets:

```diff
dependencies:
-  flutterfire_ui: ^0.4.0
+  firebase_ui_auth: ^1.0.0
```

If you're using OAuth providers:

```diff
dependencies:
# ...
+  firebase_ui_oauth: ^1.0.0
+  firebase_ui_oauth_google: ^1.0.0
+  firebase_ui_oauth_apple: ^1.0.0
```

Please make sure to depend only on those providers that are actually being used in your app. Having the provider included, but not configured might lead to unexpected behaviour.

All supported OAuth providers:

- [firebase_ui_oauth_apple](https://pub.dev/packages/firebase_ui_oauth_apple)
- [firebase_ui_oauth_facebook](https://pub.dev/packages/firebase_ui_oauth_facebook)
- [firebase_ui_oauth_google](https://pub.dev/packages/firebase_ui_oauth_google)
- [firebase_ui_oauth_twitter](https://pub.dev/packages/firebase_ui_oauth_twitter)

Make sure to update your imports as well:

```diff
- import 'package:flutterfire_ui/auth.dart';
+ import 'package:firebase_ui_auth/firebase_ui_auth.dart';
```

If you're using OAuth providers, you need to import those from corresponding packages:

```diff
// All OAuth providers used to be under flutterfire_ui
- import 'package:flutterfire_ui/auth.dart';
+ import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
```

## Code adjustments

Below is the list of necessary changes that you have to make to migrate to `firebase_ui_*` packages.

### Configuration

- `FlutterFireUIAuth` was renamed to `FirebaseUIAuth`
- instead of passing an instance of `<provider name>ProviderConfiguration` you need to pass an instance of the `<provider name>Provider`

```diff
- FlutterFireUIAuth.configureProviders([
-    const EmailProviderConfiguration(),
- ]);

+ FirebaseUIAuth.configureProviders([
+    const EmailAuthProvider(),
+ ]);
```

## Sign out

```diff
- await FlutterFireUIAuth.signOut();
+ await FirebaseUIAuth.signOut();
```

## Profile screen

If you're using `ProfileScreen` – make sure to add the following to your `pubspec.yaml`:

```yaml
fonts:
  - family: SocialIcons
    fonts:
      - asset: packages/firebase_ui_auth/fonts/SocialIcons.ttf
```

## Migrating to `firebase_ui_firestore`

To migrate from `flutterfire_ui` to `firebase_ui_firestore` you need to update your dependencies:

```diff
dependencies:
-  flutterfire_ui: ^0.4.0
+  firebase_ui_firestore: ^1.0.0
```

and imports:

```diff
- import 'package:flutterfire_ui/firestore.dart';
+ import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
```

## Migrating to `firebase_ui_database`

To migrate from `flutterfire_ui` to `firebase_ui_database` you need to update your dependencies:

```diff
dependencies:
-  flutterfire_ui: ^0.4.0
+  firebase_ui_database: ^1.0.0
```

and imports:

```diff
- import 'package:flutterfire_ui/database.dart';
+ import 'package:firebase_ui_database/firebase_ui_database.dart';
```

---

> Check out [full documentation](./README.md) for more details.
