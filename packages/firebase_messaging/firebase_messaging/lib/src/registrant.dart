// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show MessagingTokenProvider, registerFirebaseServiceFactory;
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';

/// Registers Messaging as the [MessagingTokenProvider] of every app.
///
/// The Flutter plugin registrant calls [registerWith] before `main` on
/// Android and Apple platforms (see `dartPluginClass` in pubspec.yaml), so
/// other Firebase packages can ask an app for the FCM token before the app
/// has used Messaging itself. `firebase_messaging_web` registers its own
/// provider.
class FirebaseMessagingRegistrant {
  // Not meant to be instantiated.
  FirebaseMessagingRegistrant._();

  /// Registers the [MessagingTokenProvider] factory with [FirebaseApp].
  static void registerWith() {
    registerFirebaseServiceFactory<MessagingTokenProvider>(
      FirebaseMessagingTokenProvider.new,
    );
  }
}

/// Hands out the FCM registration token Messaging holds for [app].
///
/// Resolved per app through `app.getService<MessagingTokenProvider>()`; not
/// for app code.
class FirebaseMessagingTokenProvider implements MessagingTokenProvider {
  /// Creates the provider for [app].
  FirebaseMessagingTokenProvider(this.app);

  /// The app whose Messaging instance supplies the token.
  final FirebaseApp app;

  @override
  Future<String?> getFcmToken() async {
    // Messaging serves the default app only.
    if (app.name != defaultFirebaseAppName) {
      return null;
    }
    try {
      // A delegate of its own, rather than FirebaseMessaging.instance, whose
      // getter has a foreground-message side effect. The read doesn't depend
      // on the plugin constants.
      return await FirebaseMessagingPlatform.instanceFor(
        app: app,
        pluginConstants: const {},
      ).getCachedToken();
    } catch (_) {
      // The Functions SDKs send no token when Messaging can't read one.
      return null;
    }
  }
}
