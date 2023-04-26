// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

/// A listener of the [PhoneAuthFlow] lifecycle.
abstract class PhoneAuthListener extends AuthListener {
  /// Caled when the SMS code was requested.
  /// UIs usually reflect this state with a loading indicator.
  /// Is not supported on web.
  void onSMSCodeRequested(String phoneNumber);

  /// Called when the phone number was successfully verified.
  void onVerificationCompleted(fba.PhoneAuthCredential credential);

  /// Called when the SMS code was sent.
  /// UI should provide a way to enter the code.
  void onCodeSent(String verificationId, [int? forceResendToken]);

  /// Caled when the SMS code was requested.
  /// UIs usually reflect this state with a loading indicator.
  /// Called only on web.
  void onConfirmationRequested(fba.ConfirmationResult result);
}

/// {@template ui.auth.providers.phone_auth_provider}
/// An [AuthProvider] that allows to authenticate using a phone number.
/// {@endtemplate}
class PhoneAuthProvider
    extends AuthProvider<PhoneAuthListener, fba.PhoneAuthCredential> {
  @override
  late PhoneAuthListener authListener;

  @override
  final providerId = 'phone';

  @override
  bool supportsPlatform(TargetPlatform platform) {
    return platform == TargetPlatform.android ||
        platform == TargetPlatform.iOS ||
        kIsWeb;
  }

  /// Sends an SMS code to the [phoneNumber].
  /// If [action] is [AuthAction.link], an obtained auth credential will be
  /// linked with the currently signed in user account.
  /// If [action] is [AuthAction.signIn], the user will be created (if doesn't
  /// exist) or signed in.
  void sendVerificationCode({
    String? phoneNumber,
    AuthAction action = AuthAction.signIn,
    int? forceResendingToken,

    /// {@template ui.auth.providers.phone_auth_provider.mfa_session}
    /// Multi-factor session to use for verification
    /// {@endtemplate}
    MultiFactorSession? multiFactorSession,

    /// {@template ui.auth.providers.phone_auth_provider.mfa_hint}
    /// Multi-factor session info to use for verification
    /// {@endtemplate}
    final PhoneMultiFactorInfo? hint,
  }) {
    final phone = phoneNumber ?? hint!.phoneNumber;
    authListener.onSMSCodeRequested(phone);

    if (kIsWeb) {
      _sendVerficationCodeWeb(phone, action);
    }

    auth.verifyPhoneNumber(
      forceResendingToken: forceResendingToken,
      phoneNumber: hint != null ? null : phoneNumber,
      multiFactorInfo: hint,
      multiFactorSession: multiFactorSession,
      verificationCompleted: authListener.onVerificationCompleted,
      verificationFailed: authListener.onError,
      codeSent: authListener.onCodeSent,
      codeAutoRetrievalTimeout: (_) {
        authListener.onError(AutoresolutionFailedException());
      },
    );
  }

  /// Verifies an SMS code using [verificationId] or [confirmationResult]
  /// (depending on what is currently available).
  void verifySMSCode({
    required AuthAction action,
    required String code,
    String? verificationId,
    fba.ConfirmationResult? confirmationResult,
  }) {
    if (verificationId != null) {
      final credential = fba.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );
      onCredentialReceived(credential, action);
    } else {
      confirmationResult!.confirm(code).then((userCredential) {
        if (action == AuthAction.link) {
          authListener.onCredentialLinked(userCredential.credential!);
        } else {
          authListener.onSignedIn(userCredential);
        }
      }).catchError((err) {
        authListener.onError(err);
      });
    }
  }

  void _sendVerficationCodeWeb(String phoneNumber, [AuthAction? action]) {
    Future<fba.ConfirmationResult> result;
    bool shouldLink = action == AuthAction.link || auth.currentUser != null;

    if (shouldLink) {
      result = auth.currentUser!.linkWithPhoneNumber(phoneNumber);
    } else {
      result = auth.signInWithPhoneNumber(phoneNumber);
    }

    result
        .then(authListener.onConfirmationRequested)
        .catchError(authListener.onError);
  }
}
