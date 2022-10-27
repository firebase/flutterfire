## 1.0.3

 - Update a dependency to the latest release.

## 1.0.2

 - Update a dependency to the latest release.

## 1.0.1

 - **FIX**: bump dependencies ([#9756](https://github.com/firebase/flutterfire/issues/9756)). ([595a7daa](https://github.com/firebase/flutterfire/commit/595a7daa3e856cad152463e543d152f71f61cee9))

## 1.0.0

 - Graduate package to a stable release.

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

## 1.0.0-dev.2

 - Update a dependency to the latest release.

## 1.0.0-dev.1

 - **FIX**: improve pub score ([#9722](https://github.com/firebase/flutterfire/issues/9722)). ([f27d89a1](https://github.com/firebase/flutterfire/commit/f27d89a12cbb5830eb5518854dcfbca72efedb5b))
 - **FEAT**: add firebase_ui_firestore ([#9342](https://github.com/firebase/flutterfire/issues/9342)). ([75cd372b](https://github.com/firebase/flutterfire/commit/75cd372b110fb5ca65ec684f525a4333e50c450c))

## 1.0.0-dev.0

 - Bump "firebase_ui_firestore" to `1.0.0-dev.0`.

## 0.0.1

* TODO: Describe initial release.
