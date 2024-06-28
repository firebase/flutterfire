// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:meta/meta.dart';

/// A generic provider instance.
///
/// This class is extended by other OAuth based providers, or can be used
/// standalone for integration with other 3rd party providers.
class OAuthProvider extends AuthProvider {
  // ignore: public_member_api_docs
  OAuthProvider(String providerId) : super(providerId);

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

  /// Returns the parameters for this provider instance.
  OAuthProvider setScopes(List<String> scopes) {
    _scopes = scopes;
    return this;
  }

  /// Adds OAuth scope.
  OAuthProvider addScope(String scope) {
    _scopes.add(scope);
    return this;
  }

  /// Sets the OAuth custom parameters to pass in a OAuth request for popup and
  /// redirect sign-in operations.
  OAuthProvider setCustomParameters(
    Map<String, String> customOAuthParameters,
  ) {
    _parameters = customOAuthParameters;
    return this;
  }

  /// Create a new [OAuthCredential] from a provided [accessToken];
  OAuthCredential credential({
    String? accessToken,
    String? secret,
    String? idToken,
    String? rawNonce,
    String? signInMethod,
  }) {
    return OAuthCredential(
      providerId: providerId,
      signInMethod: signInMethod ?? 'oauth',
      accessToken: accessToken,
      secret: secret,
      idToken: idToken,
      rawNonce: rawNonce,
    );
  }
}

/// A generic OAuth credential.
///
/// This class is extended by other OAuth based credentials, or can be returned
/// when generating credentials from 3rd party OAuth providers.
class OAuthCredential extends AuthCredential {
  // ignore: public_member_api_docs
  @protected
  const OAuthCredential({
    required String providerId,
    required String signInMethod,
    String? accessToken,
    this.idToken,
    this.secret,
    this.rawNonce,
    this.serverAuthCode,
    this.appleFullPersonName,
  }) : super(
          providerId: providerId,
          signInMethod: signInMethod,
          accessToken: accessToken,
        );

  /// The OAuth ID token associated with the credential if it belongs to an
  /// OIDC provider, such as `google.com`.
  final String? idToken;

  /// The OAuth access token secret associated with the credential if it belongs
  /// to an OAuth 1.0 provider, such as `twitter.com`.
  final String? secret;

  /// The raw nonce associated with the ID token. It is required when an ID
  /// token with a nonce field is provided. The SHA-256 hash of the raw nonce
  /// must match the nonce field in the ID token.
  final String? rawNonce;

  /// the server auth code for Play Games credential.
  final String? serverAuthCode;

  /// The full name of the user. Used to create an AuthCredential for the
  /// Sign in with Apple OAuth 2 provider identified by ID token, raw nonce,
  /// and full name. This method is specific to the Sign in with Apple OAuth 2
  /// provider as this provider requires the full name to be passed explicitly.
  final AppleFullPersonName? appleFullPersonName;

  @override
  Map<String, String?> asMap() {
    return <String, String?>{
      'providerId': providerId,
      'signInMethod': signInMethod,
      'idToken': idToken,
      'accessToken': accessToken,
      'secret': secret,
      'rawNonce': rawNonce,
      'serverAuthCode': serverAuthCode,
      'familyName': appleFullPersonName?.familyName,
      'givenName': appleFullPersonName?.givenName,
      'middleName': appleFullPersonName?.middleName,
      'nickname': appleFullPersonName?.nickname,
      'namePrefix': appleFullPersonName?.namePrefix,
      'nameSuffix': appleFullPersonName?.nameSuffix,
    };
  }
}
