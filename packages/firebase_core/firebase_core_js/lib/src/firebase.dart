// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core_interface/firebase_core_interface.dart'
    as core
    show Firebase;
import 'package:firebase_core_interface/firebase_core_interface.dart'
    show FirebaseApp, FirebaseOptions, FirebasePlatform, defaultFirebaseAppName;

import '../firebase_core_js.dart' show FirebaseCoreWeb;

/// The entry point for accessing Firebase in Dart web apps without Flutter.
///
/// The same API as `Firebase` in `firebase_core`. It uses [FirebaseCoreWeb]
/// unless another [FirebasePlatform] implementation is already registered, so
/// apps don't need to call [FirebaseCoreWeb.registerWith] first.
abstract final class Firebase {
  /// Returns a list of all [FirebaseApp] instances that have been created.
  static List<FirebaseApp> get apps {
    _useFirebaseCoreWeb();
    return core.Firebase.apps;
  }

  /// Initializes a new [FirebaseApp] instance by [name] and [options] and
  /// returns the created app.
  ///
  /// If a [demoProjectId] is provided, the app uses a set of default options
  /// for demo projects instead of [options], and is named [demoProjectId]
  /// unless [name] is given. By convention, [demoProjectId] begins with
  /// "demo-".
  static Future<FirebaseApp> initializeApp({
    String? name,
    FirebaseOptions? options,
    String? demoProjectId,
  }) {
    _useFirebaseCoreWeb();
    return core.Firebase.initializeApp(
      name: name,
      options: options,
      demoProjectId: demoProjectId,
    );
  }

  /// Returns a [FirebaseApp] instance.
  ///
  /// If no name is provided, the default app instance is returned.
  /// Throws if the app does not exist.
  static FirebaseApp app([String name = defaultFirebaseAppName]) {
    _useFirebaseCoreWeb();
    return core.Firebase.app(name);
  }
}

// A fallback, so that an implementation set with `FirebasePlatform.instance`,
// for example in tests, is still used.
void _useFirebaseCoreWeb() {
  FirebasePlatform.fallbackInstanceFactory ??= FirebaseCoreWeb.new;
}
