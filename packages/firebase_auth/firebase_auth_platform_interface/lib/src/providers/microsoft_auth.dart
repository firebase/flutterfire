// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';

const _kProviderId = 'microsoft.com';

/// This class should be used to either create a new Microsoft credential with an
/// access code, or use the provider to trigger user authentication flows.
///
/// For example, on web based platforms pass the provider to a Firebase method
/// (such as [signInWithPopup]):
///
/// ```dart
/// var microsoftProvider = MicrosoftAuthProvider();
/// microsoftProvider.addScope('mail.read');
/// microsoftProvider.setCustomParameters({
///   'login_hint': 'user@firstadd.onmicrosoft.com',
/// });
///
/// FirebaseAuth.instance.signInWithPopup(microsoftProvider)
///   .then(...);
/// ```
///
/// For native apps, you may also sign-in with [signInWithProvider]. Ensure you have
/// an app configured in the Microsoft Azure portal.
/// See Firebase documentation for more information: https://firebase.google.com/docs/auth/flutter/federated-auth?#microsoft
/// ```dart
/// MicrosoftAuthProvider microsoftProvider = MicrosoftAuthProvider();
/// microsoftProvider.setCustomParameters({'tenant': 'TENANT ID FROM AZURE PORTAL'},);
/// await FirebaseAuth.instance.signInWithProvider(microsoftProvider);
/// ```
class MicrosoftAuthProvider extends AuthProvider {
  /// Creates a new instance.
  MicrosoftAuthProvider() : super(_kProviderId);

  /// This corresponds to the sign-in method identifier.
  static String get MICROSOFT_SIGN_IN_METHOD {
    return _kProviderId;
  }

  // ignore: public_member_api_docs
  static String get PROVIDER_ID {
    return _kProviderId;
  }

  List<String> _scopes = [];
  Map<String, String> _parameters = {};

  /// Returns the currently assigned scopes to this provider instance.
  List<String> get scopes {
    return _scopes;
  }

  /// Returns the parameters for this provider instance.
  Map<String, String> get parameters {
    return _parameters;
  }

  /// Adds Microsoft OAuth scope.
  MicrosoftAuthProvider addScope(String scope) {
    _scopes.add(scope);
    return this;
  }

  /// Sets the OAuth custom parameters to pass in a Microsoft OAuth
  /// request for popup and redirect sign-in operations.
  MicrosoftAuthProvider setCustomParameters(
    Map<String, String> customOAuthParameters,
  ) {
    _parameters = customOAuthParameters;
    return this;
  }
}
