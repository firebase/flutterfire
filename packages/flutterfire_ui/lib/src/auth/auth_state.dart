// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutterfire_ui/auth.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart' show AuthCredential, User;

abstract class AuthState {
  const AuthState();

  static AuthState of(BuildContext context) => maybeOf(context)!;

  static AuthState? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuthStateProvider>()?.state;
}

class Uninitialized extends AuthState {
  const Uninitialized();
}

class SigningIn extends AuthState {
  const SigningIn();
}

class CredentialReceived extends AuthState {
  final AuthCredential credential;

  CredentialReceived(this.credential);
}

class CredentialLinked extends AuthState {
  final AuthCredential credential;

  CredentialLinked(this.credential);
}

class AuthFailed extends AuthState {
  final Exception exception;

  AuthFailed(this.exception);
}

class SignedIn extends AuthState {
  final User? user;

  SignedIn(this.user);
}

class DifferentSignInMethodsFound extends AuthState {
  final String email;
  final AuthCredential? credential;
  final List<String> methods;

  DifferentSignInMethodsFound(this.email, this.methods, this.credential);
}

class FetchingProvidersForEmail extends AuthState {
  const FetchingProvidersForEmail();
}

class AuthStateProvider extends InheritedWidget {
  final AuthState state;

  AuthStateProvider({
    Key? key,
    required this.state,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(AuthStateProvider oldWidget) {
    return state != oldWidget.state;
  }
}

class AuthStateTransition<T extends AuthController> extends Notification {
  final AuthState from;
  final AuthState to;
  final T controller;

  AuthStateTransition(this.from, this.to, this.controller);
}

typedef AuthStateListenerCallback<T extends AuthController> = bool? Function(
  AuthState oldState,
  AuthState state,
  T controller,
);

class AuthStateListener<T extends AuthController> extends StatelessWidget {
  final Widget child;
  final AuthStateListenerCallback<T> listener;

  const AuthStateListener({
    Key? key,
    required this.child,
    required this.listener,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (notification) {
        if (notification is! AuthStateTransition<T>) {
          return false;
        }

        return listener(
              notification.from,
              notification.to,
              notification.controller,
            ) ??
            false;
      },
      child: child,
    );
  }
}
