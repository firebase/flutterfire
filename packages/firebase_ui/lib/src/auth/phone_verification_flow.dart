import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import 'auth_controller.dart';
import 'auth_flow.dart';

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

  SMSCodeSent(this.resendToken);
}

abstract class PhoneVerificationController extends AuthController {
  void acceptPhoneNumber(String phoneNumber);
  void verifySMSCode(String code);
}

class PhoneVerificationAuthFlow extends AuthFlow
    implements PhoneVerificationController {
  final _smsCodeCompleter = Completer<String>();

  @override
  void acceptPhoneNumber(String phoneNumber) {
    auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) {
        value = PhoneVerified(credential);
        setCredentials(credential);
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
        value = PhoneVerified(credential);
        setCredentials(credential);
      },
      codeAutoRetrievalTimeout: (verificationId) {
        // TODO: handle this properly
        throw new Exception('code autoresolution failed');
      },
    );
  }

  @override
  void verifySMSCode(String code) {
    _smsCodeCompleter.complete(code);
  }
}
