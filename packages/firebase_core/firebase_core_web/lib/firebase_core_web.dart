// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The web implementation of `firebase_core`.
///
/// The implementation lives in `firebase_core_js`, which works without
/// Flutter; this package registers it as the Flutter web plugin.
library;

import 'package:firebase_core_js/firebase_core_js.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show FirebasePlatform;

import 'src/firebase_core_version.dart';

export 'package:firebase_core_js/firebase_core_js.dart';

/// Registers [FirebaseCoreWeb] as the `firebase_core` implementation in
/// Flutter web apps.
class FirebaseCoreWebPlugin {
  FirebaseCoreWebPlugin._();

  /// Called by the Flutter web plugin registrant before `main`.
  ///
  /// Call this rather than [FirebaseCoreWeb.registerWith] to register the
  /// implementation by hand in a Flutter app: it also reports the
  /// `firebase_core` version to the Firebase JS SDK.
  static void registerWith(dynamic registrar) {
    // Through the platform interface `firebase_core` reads, rather than
    // `FirebaseCoreWeb.registerWith`: with an older platform interface that
    // defines its own `FirebasePlatform`, this fails to compile instead of
    // registering an implementation `firebase_core` never sees.
    FirebasePlatform.instance = FirebaseCoreWeb();
    FirebaseCoreWeb.registerLibraryVersion('flutter-fire-core', packageVersion);
  }
}
