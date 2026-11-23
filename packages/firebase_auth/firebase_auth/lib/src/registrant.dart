// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show AuthTokenProvider, registerFirebaseServiceFactory;

/// Registers [FirebaseAuth] as the [AuthTokenProvider] of every app.
///
/// The Flutter plugin registrant calls [registerWith] before `main` on
/// Android, Apple platforms and Windows (see `dartPluginClass` in
/// pubspec.yaml), so other Firebase packages can ask an app for the ID token
/// of a user restored from a previous launch before the app has used
/// [FirebaseAuth] itself. `firebase_auth_web` registers its own provider.
class FirebaseAuthRegistrant {
  // Not meant to be instantiated.
  FirebaseAuthRegistrant._();

  /// Registers the [AuthTokenProvider] factory with [FirebaseApp].
  static void registerWith() {
    registerFirebaseServiceFactory<AuthTokenProvider>(
      FirebaseAuthTokenProvider.new,
    );
  }
}

/// Hands out the ID token of the user signed in to [FirebaseAuth] for [app].
///
/// Resolved per app through `app.getService<AuthTokenProvider>()`; not for
/// app code.
class FirebaseAuthTokenProvider implements AuthTokenProvider {
  /// Creates the provider for [app].
  FirebaseAuthTokenProvider(this.app);

  /// The app whose Auth instance supplies the token.
  final FirebaseApp app;

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    // Creating the Auth instance here is what the app would do itself; on
    // Android, Apple and Windows the native Auth SDK already exists and the
    // restored user is available synchronously.
    final user = FirebaseAuth.instanceFor(app: app).currentUser;
    return user?.getIdToken(forceRefresh);
  }
}
