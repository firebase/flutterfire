// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

/// A [UniversalEmailSignInFlow] lifecycle listener.
abstract class UniversalEmailSignInListener extends AuthListener {
  @override
  void onBeforeProvidersForEmailFetch();

  @override
  void onDifferentProvidersFound(
    String email,
    List<String> providers,
    AuthCredential? credential,
  );
}

/// A provider that resolves available authentication methods for a given
/// email.
class UniversalEmailSignInProvider
    extends AuthProvider<UniversalEmailSignInListener, AuthCredential> {
  @override
  late UniversalEmailSignInListener authListener;

  @override
  String get providerId => 'universal_email_sign_in';

  @override
  bool supportsPlatform(TargetPlatform platform) {
    return true;
  }
}
