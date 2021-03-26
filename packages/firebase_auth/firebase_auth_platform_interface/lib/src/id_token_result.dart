// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth_platform_interface/src/method_channel/utils/convert.dart';
import 'package:meta/meta.dart';

/// Interface representing ID token result obtained from [getIdTokenResult].
/// It contains the ID token JWT string and other helper properties for getting
/// different data associated with the token as well as all the decoded payload
/// claims.
///
/// Note that these claims are not to be trusted as they are parsed client side.
/// Only server side verification can guarantee the integrity of the token
/// claims.
class IdTokenResult {
  // ignore: public_member_api_docs
  @protected
  IdTokenResult(Map<String, Object?> data)
      : authTime = data['authTimestamp']
            .safeCast<int>()
            .guard((ms) => DateTime.fromMillisecondsSinceEpoch(ms)),
        claims = data['claims'].safeCast<Map<String, Object?>>(),
        expirationTime = data['expirationTimestamp']
            .safeCast<int>()
            .guard((ms) => DateTime.fromMillisecondsSinceEpoch(ms)),
        issuedAtTime = data['issuedAtTimestamp']
            .safeCast<int>()
            .guard((ms) => DateTime.fromMillisecondsSinceEpoch(ms)),
        signInProvider = data['signInProvider'] as String?,
        token = data['signInProvider'] as String?;

  /// The authentication time formatted as UTC string. This is the time the user
  /// authenticated (signed in) and not the time the token was refreshed.
  final DateTime? authTime;

  /// The entire payload claims of the ID token including the standard reserved
  /// claims as well as the custom claims.
  final Map<String, Object?>? claims;

  /// The time when the ID token expires.
  final DateTime? expirationTime;

  /// The time when ID token was issued.
  final DateTime? issuedAtTime;

  /// The sign-in provider through which the ID token was obtained (anonymous,
  /// custom, phone, password, etc). Note, this does not map to provider IDs.
  final String? signInProvider;

  /// The Firebase Auth ID token JWT string.
  final String? token;

  @override
  String toString() {
    return '$IdTokenResult(authTime: $authTime, claims: ${claims.toString()}, expirationTime: $expirationTime, issuedAtTime: $issuedAtTime, signInProvider: $signInProvider, token: $token)';
  }
}
