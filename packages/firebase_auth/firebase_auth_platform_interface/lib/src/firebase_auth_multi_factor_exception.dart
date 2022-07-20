// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:meta/meta.dart';

/// MultiFactor exception related to Firebase Authentication. Check the error code
/// and message for more details.
class FirebaseAuthMultiFactorException extends FirebaseAuthException
    implements Exception {
  // ignore: public_member_api_docs
  @protected
  FirebaseAuthMultiFactorException({
    String? message,
    required String code,
    String? email,
    AuthCredential? credential,
    String? phoneNumber,
    String? tenantId,
    required this.resolver,
  }) : super(
          message: message,
          code: code,
          email: email,
          credential: credential,
          phoneNumber: phoneNumber,
          tenantId: tenantId,
        );

  final MultiFactorResolverPlatform resolver;
}
