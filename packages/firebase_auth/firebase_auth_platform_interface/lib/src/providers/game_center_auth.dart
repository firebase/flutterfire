// Copyright 2024 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';

const _kProviderId = 'gc.apple.com';

/// This class should be used to create a new Game Center credential
/// to trigger an authentication flow on Apple platform.
///
/// ```dart
/// // Requires authenticating with game center before proceeding with the below:
/// final gameCenterCredential = GameCenterAuthProvider.credential();
///
/// FirebaseAuth.instance.signInWithCredential(gameCenterCredential)
///  .then(...);
/// ```
class GameCenterAuthProvider extends AuthProvider {
  /// Creates a new instance.
  GameCenterAuthProvider() : super(_kProviderId);

  /// Create a new [GameCenterAuthCredential] to be used on FlutterFire
  /// Auth plugin only.
  static OAuthCredential credential() {
    return GameCenterAuthCredential._credential();
  }

  /// This corresponds to the sign-in method identifier.
  static String get GAME_CENTER_SIGN_IN_METHOD {
    return _kProviderId;
  }

  // ignore: public_member_api_docs
  static String get PROVIDER_ID {
    return _kProviderId;
  }

  Map<String, String> _parameters = {};

  /// Returns the parameters for this provider instance.
  Map<String, String> get parameters {
    return _parameters;
  }

  /// Sets the OAuth custom parameters to pass in a Game Center OAuth request for
  /// popup and redirect sign-in operations.
  GameCenterAuthProvider setCustomParameters(
    Map<String, String> customOAuthParameters,
  ) {
    _parameters = customOAuthParameters;
    return this;
  }
}

/// The auth credential returned from calling
/// [GameCenterAuthProvider.credential].
class GameCenterAuthCredential extends OAuthCredential {
  GameCenterAuthCredential._()
      : super(
          providerId: _kProviderId,
          signInMethod: _kProviderId,
        );

  factory GameCenterAuthCredential._credential() {
    return GameCenterAuthCredential._();
  }
}
