// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_auth;

class OAuthProvider {
  const OAuthProvider({@required this.providerId}) : assert(providerId != null);

  /// The provider ID with which this provider is associated
  final String providerId;

  /// Creates an [OAuthCredential] for the OAuth 2 provider with the provided parameters.
  OAuthCredential getCredential({
    @required String idToken,
    String accessToken,
    String rawNonce,
  }) {
    return PlatformOAuthCredential(
        providerId: providerId,
        idToken: idToken,
        accessToken: accessToken,
        rawNonce: rawNonce);
  }
}
