// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui/auth.dart';

import '../auth_flow.dart';

class AwaitingPhoneNumber extends AuthState {}

class SMSCodeRequested extends AuthState {}

class PhoneVerified extends AuthState {
  final AuthCredential credential;

  PhoneVerified(this.credential);
}

class PhoneVerificationFailed extends AuthState {
  final FirebaseAuthException exception;

  PhoneVerificationFailed(this.exception);
}

class SMSCodeSent extends AuthState {
  final int? resendToken;

  SMSCodeSent([this.resendToken]);
}

class AutoresolutionFailedException implements Exception {
  final String message;

  AutoresolutionFailedException([
    this.message = 'SMS code autoresolution failed',
  ]);
}

abstract class PhoneAuthController extends AuthController {
  void acceptPhoneNumber(String phoneNumber);
  void verifySMSCode(String code);
}

class PhoneAuthFlow extends AuthFlow implements PhoneAuthController {
  final _smsCodeCompleter = Completer<String>();

  PhoneAuthFlow({
    FirebaseAuth? auth,
    AuthAction? action,
  }) : super(auth: auth, initialState: AwaitingPhoneNumber(), action: action);

  @override
  Future<void> acceptPhoneNumber(String phoneNumber) async {
    value = SMSCodeRequested();

    try {
      if (kIsWeb) {
        return await _webSignIn(phoneNumber);
      }

      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) async {
          value = PhoneVerified(credential);
          await Future.delayed(const Duration(milliseconds: 300));
          setCredential(credential);
        },
        verificationFailed: (exception) {
          value = PhoneVerificationFailed(exception);
        },
        codeSent: (String verificationId, int? resendToken) async {
          value = SMSCodeSent(resendToken);
          final code = await _smsCodeCompleter.future;
          final credential = PhoneAuthProvider.credential(
            verificationId: verificationId,
            smsCode: code,
          );

          setCredential(credential);
        },
        codeAutoRetrievalTimeout: (verificationId) {
          value = AuthFailed(AutoresolutionFailedException());
        },
      );
    } on Exception catch (err) {
      value = AuthFailed(err);
    }
  }

  @override
  void verifySMSCode(String code) {
    _smsCodeCompleter.complete(code);
  }

  Future<void> _webSignIn(String phoneNumber) async {
    ConfirmationResult result;
    bool shouldLink = auth.currentUser != null;

    if (shouldLink) {
      result = await auth.currentUser!.linkWithPhoneNumber(phoneNumber);
    } else {
      result = await auth.signInWithPhoneNumber(phoneNumber);
    }

    value = SMSCodeSent();

    final smsCode = await _smsCodeCompleter.future;
    final userCredential = await result.confirm(smsCode);

    if (shouldLink) {
      value = CredentialLinked(
        PhoneAuthProvider.credential(
          verificationId: result.verificationId,
          smsCode: smsCode,
        ),
      );
    } else {
      value = SignedIn(userCredential.user);
    }
  }
}

class VerifyPhoneAction extends FlutterFireUIAction {
  final void Function(BuildContext context, AuthAction? action) callback;

  VerifyPhoneAction(this.callback);
}

class SMSCodeRequestedAction extends FlutterFireUIAction {
  final void Function(
    BuildContext context,
    AuthAction? action,
    Object flowKey,
    String phoneNumber,
  ) callback;

  SMSCodeRequestedAction(this.callback);
}
