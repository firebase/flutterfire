// Copyright 2024 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';

const _kProviderId = 'playgames.google.com';

/// This class should be used to either create a new Play Games credential with an
/// access code, or use the provider to trigger user authentication flows.
///
/// If authenticating with Play Games via a 3rd party, use the returned
/// `serverAuthCode` to sign-in or link the user with the created credential,
/// for example:
///
/// ```dart
/// String serverAuthCode = '...'; // From 3rd party provider
/// var playGamesAuthCredential = PlayGamesAuthCredential.credential(serverAuthCode: serverAuthCode);
///
/// FirebaseAuth.instance.signInWithCredential(playGamesAuthCredential)
///   .then(...);
/// ```
class PlayGamesAuthProvider extends AuthProvider {
  /// Creates a new instance.
  PlayGamesAuthProvider() : super(_kProviderId);

  /// Create a new [PlayGamesAuthCredential] from a provided [serverAuthCode]
  static OAuthCredential credential({
    required String serverAuthCode,
  }) {
    return PlayGamesAuthCredential._credential(
      serverAuthCode: serverAuthCode,
    );
  }

  /// This corresponds to the sign-in method identifier.
  static String get PLAY_GAMES_SIGN_IN_METHOD {
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

  /// Sets the OAuth custom parameters to pass in a Play Games OAuth request for
  /// popup and redirect sign-in operations.
  PlayGamesAuthProvider setCustomParameters(
    Map<String, String> customOAuthParameters,
  ) {
    _parameters = customOAuthParameters;
    return this;
  }
}

/// The auth credential returned from calling
/// [PlayGamesAuthProvider.credential].
class PlayGamesAuthCredential extends OAuthCredential {
  PlayGamesAuthCredential._({
    required String serverAuthCode,
  }) : super(
          providerId: _kProviderId,
          signInMethod: _kProviderId,
          serverAuthCode: serverAuthCode,
        );

  factory PlayGamesAuthCredential._credential({
    required String serverAuthCode,
  }) {
    return PlayGamesAuthCredential._(serverAuthCode: serverAuthCode);
  }
}
