import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:flutter/foundation.dart';
import 'package:flutterfire_ui/auth.dart';

abstract class PhoneAuthListener extends AuthListener {
  void onSMSCodeRequested(String phoneNumber);
  void onVerificationCompleted(fba.PhoneAuthCredential credential);
  void onCodeSent(String verificationId, [int? forceResendToken]);
  void onConfirmationRequested(fba.ConfirmationResult result);
}

class PhoneAuthProvider
    extends AuthProvider<PhoneAuthListener, fba.PhoneAuthCredential> {
  @override
  late PhoneAuthListener authListener;

  @override
  final providerId = 'phone';

  @override
  bool supportsPlatform(TargetPlatform platform) {
    return true;
  }

  void sendVerificationCode(String phoneNumber, AuthAction action) {
    authListener.onSMSCodeRequested(phoneNumber);

    if (kIsWeb) {
      _sendVerficationCodeWeb(phoneNumber, action);
    }

    auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: authListener.onVerificationCompleted,
      verificationFailed: authListener.onError,
      codeSent: authListener.onCodeSent,
      codeAutoRetrievalTimeout: (_) {
        authListener.onError(AutoresolutionFailedException());
      },
    );
  }

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
