// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth_platform_interface/src/auth_exception_status_code.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:meta/meta.dart';
import 'auth_credential.dart';

/// Generic exception related to Firebase Authentication. Check the error code
/// and message for more details.
class FirebaseAuthException extends FirebaseException implements Exception {
  // ignore: public_member_api_docs
  @protected
  FirebaseAuthException(
      {@required this.message,
      String code,
      this.email,
      this.credential,
      this.phoneNumber,
      this.tenantId})
      : super(plugin: 'firebase_auth', message: message, code: code);

  @Deprecated('Deprecated in favor of `.statusCode`.')
  String get code => super.code;

  /// Complete error message.
  final String message;

  /// The email of the user's account used for sign-in/linking.
  final String email;

  /// The [AuthCredential] that can be used to resolve the error.
  final AuthCredential credential;

  /// The phone number of the user's account used for sign-in/linking.
  final String phoneNumber;

  /// The tenant ID being used for sign-in/linking.
  final String tenantId;

  /// The error code.
  AuthExceptionStatusCode get statusCode {
    switch (super.code) {
      case 'invalid-email':
        return AuthExceptionStatusCode.invalidEmail;
      case 'user-disabled':
        return AuthExceptionStatusCode.userDisabled;
      case 'user-not-found':
        return AuthExceptionStatusCode.userNotFound;
      case 'wrong-password':
        return AuthExceptionStatusCode.wrongPassword;
      case 'too-many-requests':
        return AuthExceptionStatusCode.tooManyRequests;
      case 'operation-not-allowed':
        return AuthExceptionStatusCode.operationNotAllowed;
      case 'account-exists-with-different-credential':
        return AuthExceptionStatusCode.accountExistsWithDifferentCredential;
      case 'network-request-failed':
        return AuthExceptionStatusCode.networkRequestFailed;
      case 'email-already-in-use':
        return AuthExceptionStatusCode.emailAlreadyInUse;
      case 'weak-password':
        return AuthExceptionStatusCode.weakPassword;
      case 'invalid-phone-number':
        return AuthExceptionStatusCode.invalidPhoneNumber;
      case 'invalid-verification-id':
        return AuthExceptionStatusCode.invalidVerificationId;
      case 'user-mismatch':
        return AuthExceptionStatusCode.userMismatch;
      case 'no-such-provider':
        return AuthExceptionStatusCode.noSuchProvider;
      case 'no-current-user':
        return AuthExceptionStatusCode.noCurrentUser;
      default:
        return AuthExceptionStatusCode.unknown;
    }
  }
}
