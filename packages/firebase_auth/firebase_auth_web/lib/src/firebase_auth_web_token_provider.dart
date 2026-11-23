// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show AuthTokenProvider;
import 'package:firebase_core_web/firebase_core_web_interop.dart'
    as core_interop;

import 'interop/auth.dart' as auth_interop;
import 'utils/web_utils.dart';

/// Hands out the ID token of the user signed in to the JS Auth instance of
/// [app].
///
/// `FirebaseAuthWeb.registerWith` registers it as the app's
/// [AuthTokenProvider]. Resolved per app through
/// `app.getService<AuthTokenProvider>()`; not for app code.
class FirebaseAuthWebTokenProvider implements AuthTokenProvider {
  /// Creates the provider for [app].
  FirebaseAuthWebTokenProvider(this.app);

  /// The app whose Auth instance supplies the token.
  final FirebaseApp app;

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    // The JS Auth instance exists since Firebase.initializeApp: the web plugin
    // initializes it there and waits for the restored user.
    final auth = auth_interop.getAuthInstance(core_interop.app(app.name));
    final user = auth.currentUser;
    if (user == null) {
      return null;
    }
    return guardAuthExceptions(() => user.getIdToken(forceRefresh), auth: auth);
  }
}
