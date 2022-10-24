// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart'
    show AuthCredential, FirebaseAuth, User;
import 'package:flutter/widgets.dart';

enum AuthAction {
  signIn,
  signUp,
  link,
}

abstract class AuthController {
  static T ofType<T extends AuthController>(BuildContext context) {
    final ctrl = context
        .dependOnInheritedWidgetOfExactType<AuthControllerProvider>()
        ?.ctrl;

    if (ctrl == null || ctrl is! T) {
      throw Exception(
        'No controller of type $T found. '
        'Make sure to wrap your code with AuthFlowBuilder<$T>',
      );
    }

    return ctrl;
  }

  AuthAction get action;
  FirebaseAuth get auth;

  Future<User?> signIn(AuthCredential credential);

  Future<void> link(AuthCredential credential);

  Future<List<String>> findProvidersForEmail(
    String email, {
    AuthCredential? credential,
  });

  void reset();
}

class AuthControllerProvider extends InheritedWidget {
  final AuthAction action;
  final AuthController ctrl;

  AuthControllerProvider({
    required Widget child,
    required this.action,
    required this.ctrl,
  }) : super(child: child);

  @override
  bool updateShouldNotify(AuthControllerProvider oldWidget) {
    return ctrl != oldWidget.ctrl || action != oldWidget.action;
  }
}
