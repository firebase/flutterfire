// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show MessagingTokenProvider;
import 'package:firebase_messaging_web/firebase_messaging_web.dart';

/// Hands out the FCM registration token Messaging holds for [app].
///
/// `FirebaseMessagingWeb.registerWith` registers it as the app's
/// [MessagingTokenProvider]. Resolved per app through
/// `app.getService<MessagingTokenProvider>()`; not for app code.
class FirebaseMessagingWebTokenProvider implements MessagingTokenProvider {
  /// Creates the provider for [app].
  FirebaseMessagingWebTokenProvider(this.app);

  /// The app whose Messaging instance supplies the token.
  final FirebaseApp app;

  @override
  Future<String?> getFcmToken() async {
    // Messaging serves the default app only.
    if (app.name != defaultFirebaseAppName) {
      return null;
    }
    try {
      return await FirebaseMessagingWeb(app: app).getCachedToken();
    } catch (_) {
      // The Functions SDKs send no token when Messaging can't read one.
      return null;
    }
  }
}
