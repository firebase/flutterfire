// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

/// A listener of the [EmailAuthFlow] flow lifecycle.
abstract class EmailAuthListener extends AuthListener {}

/// {@template ui.auth.providers.email_auth_provider}
/// An [AuthProvider] that allows to authenticate using email and password.
/// {@endtemplate}
class EmailAuthProvider
    extends AuthProvider<EmailAuthListener, fba.EmailAuthCredential> {
  @override
  late EmailAuthListener authListener;

  @override
  final providerId = 'password';

  @override
  bool supportsPlatform(TargetPlatform platform) => true;

  /// Tries to create a new user account with the given [EmailAuthCredential].
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

  /// Creates an [EmailAuthCredential] with the given [email] and [password] and
  /// performs a corresponding [AuthAction].
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
    fba.EmailAuthCredential credential,
    AuthAction action,
  ) {
    switch (action) {
      case AuthAction.signIn:
        signInWithCredential(credential);
        break;
      case AuthAction.signUp:
        if (shouldUpgradeAnonymous) {
          return linkWithCredential(credential);
        }

        signUpWithCredential(credential);
        break;
      case AuthAction.link:
        linkWithCredential(credential);
        break;
      case AuthAction.none:
        super.onCredentialReceived(credential, action);
        break;
    }
  }
}
