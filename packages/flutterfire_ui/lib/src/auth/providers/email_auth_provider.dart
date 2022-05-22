import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

abstract class EmailAuthListener extends AuthListener {}

class EmailAuthProvider
    extends AuthProvider<EmailAuthListener, EmailAuthCredential> {
  @override
  late EmailAuthListener authListener;

  @override
  final providerId = 'email';

  @override
  bool supportsPlatform(TargetPlatform platform) => true;

  void signUpWithCredential(EmailAuthCredential credential) {
    authListener.onBeforeSignIn();
    auth
        .createUserWithEmailAndPassword(
          email: credential.email,
          password: credential.password!,
        )
        .then(authListener.onSignedIn)
        .catchError(authListener.onError);
  }

  @override
  void onCredentialReceived(EmailAuthCredential credential, AuthAction action) {
    if (action == AuthAction.signUp) {
      signUpWithCredential(credential);
    } else {
      super.onCredentialReceived(credential, action);
    }
  }
}
