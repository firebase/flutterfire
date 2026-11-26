// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show
        AppCheckInteropToken,
        AppCheckTokenProvider,
        registerFirebaseServiceFactory;

/// Registers [FirebaseAppCheck] as the [AppCheckTokenProvider] of every app.
///
/// The Flutter plugin registrant calls [registerWith] before `main` on
/// Android, Apple platforms and Windows (see `dartPluginClass` in
/// pubspec.yaml), so other Firebase packages can ask an app for an App Check
/// token before the app has used [FirebaseAppCheck] itself.
/// `firebase_app_check_web` registers its own provider.
class FirebaseAppCheckRegistrant {
  // Not meant to be instantiated.
  FirebaseAppCheckRegistrant._();

  /// Registers the [AppCheckTokenProvider] factory with [FirebaseApp].
  static void registerWith() {
    registerFirebaseServiceFactory<AppCheckTokenProvider>(
      FirebaseAppCheckTokenProvider.new,
    );
  }
}

/// Hands out [FirebaseAppCheck]'s tokens for [app] in the shape the Firebase
/// SDKs hand each other.
///
/// Resolved per app through `app.getService<AppCheckTokenProvider>()`; not for
/// app code.
class FirebaseAppCheckTokenProvider implements AppCheckTokenProvider {
  /// Creates the provider for [app].
  FirebaseAppCheckTokenProvider(this.app);

  /// The app whose App Check instance supplies the token.
  final FirebaseApp app;

  @override
  Future<AppCheckInteropToken?> getToken({bool limitedUse = false}) async {
    // Creating the App Check instance here is what the app would do itself;
    // until the app activates it, the SDK has no provider and the request
    // below fails.
    final appCheck = FirebaseAppCheck.instanceFor(app: app);
    try {
      final token = limitedUse
          ? await appCheck.getLimitedUseToken()
          : await appCheck.getToken();
      return token == null ? null : AppCheckInteropToken(token: token);
    } catch (error) {
      // The SDKs answer a failed request, including one before activation,
      // with their placeholder token and the reason; the plugin's public API
      // throws instead.
      return AppCheckInteropToken.failure(switch (error) {
        FirebaseException(:final message?) => message,
        FirebaseException(:final code) => code,
        _ => '$error',
      });
    }
  }
}
