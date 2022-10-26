// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_file: unnecessary_this

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'auth_state.dart';
import 'auth_controller.dart';

class AuthCancelledException implements Exception {
  AuthCancelledException([this.message = 'User has cancelled auth']);

  final String message;
}

class AuthFlow extends ValueNotifier<AuthState> implements AuthController {
  @override
  final FirebaseAuth auth;
  final AuthState initialState;
  AuthAction? _action;
  List<VoidCallback> _onDispose = [];

  @override
  AuthAction get action {
    if (_action != null) {
      return _action!;
    }

    if (auth.currentUser != null) {
      return AuthAction.link;
    }

    return AuthAction.signIn;
  }

  set action(AuthAction value) {
    _action = value;
  }

  VoidCallback get onDispose {
    return () {
      _onDispose.forEach((callback) => callback());
    };
  }

  set onDispose(VoidCallback callback) {
    _onDispose.add(callback);
  }

  AuthFlow({
    FirebaseAuth? auth,
    AuthAction? action,
    required this.initialState,
  })  : auth = auth ?? FirebaseAuth.instance,
        _action = action,
        super(initialState);

  void setCredential(AuthCredential credential) {
    onCredentialReceived(credential);
  }

  @override
  Future<User?> signIn(AuthCredential credential) async {
    final userCredential = await auth.signInWithCredential(credential);
    return userCredential.user;
  }

  @override
  Future<void> link(AuthCredential credential) async {
    final user = auth.currentUser;

    if (user != null) {
      try {
        await user.linkWithCredential(credential);
      } on Exception catch (err) {
        value = AuthFailed(err);
      }
    } else {
      throw Exception(
        "Can't link the credential: no user is currently signed in",
      );
    }
  }

  @override
  Future<List<String>> findProvidersForEmail(
    String email, {
    AuthCredential? credential,
  }) async {
    value = const FetchingProvidersForEmail();
    try {
      final methods = await auth.fetchSignInMethodsForEmail(email);
      value = DifferentSignInMethodsFound(email, methods, credential);
      return methods;
    } on Exception catch (err) {
      value = AuthFailed(err);
      rethrow;
    }
  }

  Future<void> onCredentialReceived(AuthCredential credential) async {
    late AuthState finalState;
    try {
      switch (action) {
        case AuthAction.signIn:
          value = const SigningIn();
          try {
            final user = await signIn(credential);

            if (user != null) {
              finalState = SignedIn(user);
            }
          } on Exception catch (err) {
            return handleError(err);
          }

          break;
        case AuthAction.link:
          value = CredentialReceived(credential);
          await link(credential);
          finalState = CredentialLinked(credential);
          break;
        default:
          throw Exception('$action is not supported by $runtimeType');
      }

      if (value is! AuthFailed) {
        value = finalState;
      }
    } on Exception catch (err) {
      value = AuthFailed(err);
    }
  }

  void handleError(Exception exception) {
    if (exception is! FirebaseAuthException) {
      value = AuthFailed(exception);
      return;
    }

    if (exception.code == 'account-exists-with-different-credential') {
      final email = exception.email;
      if (email == null) {
        value = AuthFailed(exception);
        return;
      }

      findProvidersForEmail(email, credential: exception.credential);
      return;
    }

    value = AuthFailed(exception);
  }

  @override
  void reset() {
    value = initialState;
    onDispose();
  }
}
