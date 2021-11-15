import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../auth_controller.dart';
import '../auth_flow.dart';
import '../auth_state.dart';

class AwaitingPhoneNumber extends AuthState {}

class SMSCodeRequested extends AuthState {}

class PhoneVerified extends AuthState {
  final PhoneAuthCredential credential;

  PhoneVerified(this.credential);
}

class PhoneVerificationFailed extends AuthState {
  final FirebaseAuthException exception;

  PhoneVerificationFailed(this.exception);
}

class SMSCodeSent extends AuthState {
  final int? resendToken;

  SMSCodeSent(this.resendToken);
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
}
