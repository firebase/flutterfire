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

abstract class AuthFlow extends ValueNotifier<AuthState>
    implements AuthController {
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

          if (user != null) {
            finalState = SignedIn(user);
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

  @override
  void reset() {
    value = initialState;
    onDispose();
  }
}
