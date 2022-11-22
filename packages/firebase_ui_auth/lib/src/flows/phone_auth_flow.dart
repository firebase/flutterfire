// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:flutter/widgets.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

/// An [AuthState] that indicates that [PhoneAuthFlow] is not yet initialized
/// wuth the phone number. UI should provide a way to submit a phone number.
class AwaitingPhoneNumber extends AuthState {}

/// An [AuthState] that indicates that the phone number was submitted and the SMS
/// code is being sent. UIs often reflect this state with a loading indicator.
class SMSCodeRequested extends AuthState {
  /// The phone number that was submitted.
  final String phoneNumber;

  const SMSCodeRequested(this.phoneNumber);
}

/// An [AuthState] that indicates that the SMS code was sucessfully veriied and
/// a [fba.AuthCredential] was obtained.
class PhoneVerified extends AuthState {
  /// An [fba.AuthCredential] that was obtained during authentication process.
  final fba.AuthCredential credential;

  PhoneVerified(this.credential);
}

/// Indicates that the phone verification failed.
/// [exception] contains the details describing what exactly went wrong.
class PhoneVerificationFailed extends AuthState {
  /// A [fba.FirebaseAuthException] that contains the details about the error.
  final fba.FirebaseAuthException exception;

  PhoneVerificationFailed(this.exception);
}

/// {@template ui.auth.flows.phone_auth_flow}
/// A state that indicates that the SMS code was successfully sent and the user
/// should submit it. UI should provide a way to submit the SMS code.
/// {@endtemplate}
class SMSCodeSent extends AuthState {
  /// Verification ID that should be used to verify the phone number.
  String? verificationId;

  /// A token that should be used to trigger another send attempt.
  final int? resendToken;

  /// Web-only object that is being used to verify the phone number.
  fba.ConfirmationResult? confirmationResult;

  /// {@macro ui.auth.flows.phone_auth_flow}
  SMSCodeSent({
    this.verificationId,
    this.resendToken,
    this.confirmationResult,
  });
}

/// {@template ui.auth.flows.autoresolution_failed_exception}
/// A state that indicates that autoresolution has failed.
/// This doesn't necessarily mean that the code was invalid, sometimes
/// a device doesn't support SMS code autoresolution.
/// {@endtemplate}
class AutoresolutionFailedException implements Exception {
  final String message;

  /// {@macro ui.auth.flows.autoresolution_failed_exception}
  AutoresolutionFailedException([
    this.message = 'SMS code autoresolution failed',
  ]);
}

/// A controller interface of the [PhoneAuthFlow].
abstract class PhoneAuthController extends AuthController {
  /// Initializes the flow with a phone number. This method should be called
  /// after user submits a phone number.
  void acceptPhoneNumber(
    String phoneNumber, [
    fba.MultiFactorSession? multiFactorSession,
  ]);

  /// Triggers an SMS code verification.
  void verifySMSCode(
    String code, {
    String? verificationId,
    fba.ConfirmationResult? confirmationResult,
  });
}

/// {@template ui.auth.flows.phone_auth_flow}
/// An auth flow that allows authentication with a phone number.
/// {@endtemplate}
class PhoneAuthFlow extends AuthFlow<PhoneAuthProvider>
    implements PhoneAuthController, PhoneAuthListener {
  /// A verification ID that is being used to verify the phone number.
  /// Not available on web, [confirmationResult] should be used instead.
  String? verificationId;

  /// Web-only object that should be used to verify the phone number.
  fba.ConfirmationResult? confirmationResult;

  /// {@macro ui.auth.flows.phone_auth_flow}
  PhoneAuthFlow({
    /// {@macro ui.auth.auth_flow.ctor.provider}
    required PhoneAuthProvider provider,

    /// {@macro ui.auth.auth_controller.auth}
    fba.FirebaseAuth? auth,

    /// {@macro @macro ui.auth.auth_action}
    AuthAction? action,
  }) : super(
          auth: auth,
          initialState: AwaitingPhoneNumber(),
          action: action,
          provider: provider,
        );

  @override
  void acceptPhoneNumber(
    String phoneNumber, [
    fba.MultiFactorSession? multiFactorSession,
  ]) {
    provider.sendVerificationCode(
      phoneNumber: phoneNumber,
      action: action,
      multiFactorSession: multiFactorSession,
    );
  }

  @override
  void verifySMSCode(
    String code, {
    String? verificationId,
    fba.ConfirmationResult? confirmationResult,
    fba.MultiFactorSession? multiFactorSession,
  }) {
    provider.verifySMSCode(
      action: action,
      code: code,
      verificationId: verificationId,
      confirmationResult: confirmationResult,
    );
  }

  @override
  void onCodeSent(String verificationId, [int? forceResendToken]) {
    value = SMSCodeSent(
      verificationId: verificationId,
      resendToken: forceResendToken,
    );
  }

  @override
  void onSMSCodeRequested(String phoneNumber) {
    value = SMSCodeRequested(phoneNumber);
  }

  @override
  void onVerificationCompleted(fba.PhoneAuthCredential credential) {
    value = PhoneVerified(credential);
    provider.onCredentialReceived(credential, action);
  }

  @override
  void onConfirmationRequested(fba.ConfirmationResult result) {
    value = SMSCodeSent(confirmationResult: result);
  }
}

/// {@template ui.auth.flows.phone_auth_flow.verify_phone_number}
/// An action that is called when user requests a sign in with the phone number.
/// Could be used to show a [PhoneInputScreen] or trigger a custom
/// logic:
///
/// ```dart
/// SignInScreen(
///   actions: [
///     VerifyPhoneAction((context, action) {
///       Navigator.of(context).push(
///         MaterialPageRoute(
///           builder: (context) => PhoneInputScreen(),
///         ),
///       );
///     }),
///   ]
/// );
/// ```
/// {@endtemplate}
class VerifyPhoneAction extends FirebaseUIAction {
  /// A callback that is being called when the user requests a sign in with the
  /// phone number.
  final void Function(BuildContext context, AuthAction? action) callback;

  /// {@macro ui.auth.flows.phone_auth_flow.verify_phone_number}
  VerifyPhoneAction(this.callback);
}

/// {@template ui.auth.flows.phone_auth_flow.sms_code_requested_action}
/// An action that is called when user requests a sign in with the phone number.
/// Could be used to show a [SMSCodeInputScreen] or trigger a custom
/// logic:
///
/// ```dart
/// SignInScreen(
///   actions: [
///     SMSCodeRequestedAction((context, action, flowKey, phoneNumber) {
///       Navigator.of(context).push(
///         MaterialPageRoute(
///           builder: (context) => SMSCodeInputScreen(),
///         ),
///       );
///     }),
///   ]
/// );
/// ```
/// {@endtemplate}
class SMSCodeRequestedAction extends FirebaseUIAction {
  final void Function(
    BuildContext context,
    AuthAction? action,
    Object flowKey,
    String phoneNumber,
  ) callback;

  /// {@macro ui.auth.flows.phone_auth_flow.sms_code_requested_action}
  SMSCodeRequestedAction(this.callback);
}
