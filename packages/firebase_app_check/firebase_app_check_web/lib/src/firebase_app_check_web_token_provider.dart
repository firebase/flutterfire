// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_app_check_platform_interface/firebase_app_check_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show AppCheckInteropToken, AppCheckTokenProvider;

/// Hands out the App Check tokens of [app] in the shape the Firebase SDKs
/// hand each other.
///
/// `FirebaseAppCheckWeb.registerWith` registers it as the app's
/// [AppCheckTokenProvider]. Resolved per app through
/// `app.getService<AppCheckTokenProvider>()`; not for app code.
class FirebaseAppCheckWebTokenProvider implements AppCheckTokenProvider {
  /// Creates the provider for [app].
  FirebaseAppCheckWebTokenProvider(this.app);

  /// The app whose App Check instance supplies the token.
  final FirebaseApp app;

  @override
  Future<AppCheckInteropToken?> getToken({bool limitedUse = false}) async {
    // Every web delegate for an app shares its activated JS instance, so this
    // sees the activation the app did through FirebaseAppCheck.
    final appCheck = FirebaseAppCheckPlatform.instanceFor(app: app);
    try {
      final token = limitedUse
          ? await appCheck.getLimitedUseToken()
          : await appCheck.getToken(false);
      return token == null ? null : AppCheckInteropToken(token: token);
    } catch (error) {
      // Before activation, and on any other failure, the plugin throws; the
      // SDKs answer each other with the placeholder and the reason.
      return AppCheckInteropToken.failure(switch (error) {
        FirebaseException(:final message?) => message,
        FirebaseException(:final code) => code,
        _ => '$error',
      });
    }
  }
}
