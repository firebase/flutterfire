import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

abstract class EmailAuthListener extends AuthListener {}

class EmailAuthProvider
    extends AuthProvider<EmailAuthListener, fba.EmailAuthCredential> {
  @override
  late EmailAuthListener authListener;

  @override
  final providerId = 'password';

  @override
  bool supportsPlatform(TargetPlatform platform) => true;

  void signUpWithCredential(fba.EmailAuthCredential credential) {
    authListener.onBeforeSignIn();
    auth
        .createUserWithEmailAndPassword(
          email: credential.email,
          password: credential.password!,
        )
        .then(authListener.onSignedIn)
        .catchError(authListener.onError);
  }

  void authenticate(
    String email,
    String password, [
    AuthAction action = AuthAction.signIn,
  ]) {
    final credential = fba.EmailAuthProvider.credential(
      email: email,
      password: password,
    ) as fba.EmailAuthCredential;

    onCredentialReceived(credential, action);
  }

  @override
  void onCredentialReceived(
      fba.EmailAuthCredential credential, AuthAction action) {
    if (action == AuthAction.signUp) {
      signUpWithCredential(credential);
    } else {
      super.onCredentialReceived(credential, action);
    }
  }
}
