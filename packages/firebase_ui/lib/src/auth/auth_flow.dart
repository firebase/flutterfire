import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../firebase_ui_init.dart';
import 'auth_state.dart';
import 'auth_controller.dart';

abstract class AuthFlow extends ValueNotifier<AuthState>
    with InitializerProvider
    implements AuthController {
  BuildContext? context;

  @override
  final FirebaseAuth auth;

  final AuthState initialState;

  @override
  AuthAction action;

  AuthFlow({
    required this.auth,
    required this.initialState,
    required this.action,
  }) : super(initialState);

  void setCredential(AuthCredential credential) {
    onCredentialReceived(credential);
  }

  @override
  Future<User?> signIn(AuthCredential credential) async {
    try {
      return (await auth.signInWithCredential(credential)).user;
    } on Exception catch (err) {
      value = AuthFailed(err);
    }
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

  Future<void> onCredentialReceived(AuthCredential credential) async {
    late AuthState finalState;
    try {
      switch (action) {
        case AuthAction.signIn:
          value = const SigningIn();
          final user = await signIn(credential);
          finalState = SignedIn(user!);
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

  T resolveInitializer<T>() {
    return getInitializerOfType<T>(context!);
  }

  @override
  void reset() {
    value = initialState;
  }
}
