import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui/auth.dart';

class AwaitingPhoneNumber extends AuthState {}

class SMSCodeRequested extends AuthState {
  final String phoneNumber;

  const SMSCodeRequested(this.phoneNumber);
}

class PhoneVerified extends AuthState {
  final fba.AuthCredential credential;

  PhoneVerified(this.credential);
}

class PhoneVerificationFailed extends AuthState {
  final fba.FirebaseAuthException exception;

  PhoneVerificationFailed(this.exception);
}

class SMSCodeSent extends AuthState {
  String? verificationId;
  final int? resendToken;
  fba.ConfirmationResult? confirmationResult;

  SMSCodeSent({
    this.verificationId,
    this.resendToken,
    this.confirmationResult,
  });
}

class AutoresolutionFailedException implements Exception {
  final String message;

  AutoresolutionFailedException([
    this.message = 'SMS code autoresolution failed',
  ]);
}

abstract class PhoneAuthController extends AuthController {
  void acceptPhoneNumber(String phoneNumber);
  void verifySMSCode(
    String code, {
    String? verificationId,
    fba.ConfirmationResult? confirmationResult,
  });
}

class PhoneAuthFlow extends AuthFlow<PhoneAuthProvider>
    implements PhoneAuthController, PhoneAuthListener {
  String? verificationId;
  fba.ConfirmationResult? confirmationResult;

  PhoneAuthFlow({
    required PhoneAuthProvider provider,
    fba.FirebaseAuth? auth,
    AuthAction? action,
  }) : super(
          auth: auth,
          initialState: AwaitingPhoneNumber(),
          action: action,
          provider: provider,
        );

  @override
  void acceptPhoneNumber(String phoneNumber) {
    provider.sendVerificationCode(phoneNumber, action);
  }

  @override
  void verifySMSCode(
    String code, {
    String? verificationId,
    fba.ConfirmationResult? confirmationResult,
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
