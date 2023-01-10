// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

/// A state that indicates that email flow is not initialized with an email and
/// password. UI should show an [EmailForm] when [EmailAuthFlow]'s current state is
/// [AwaitingEmailAndPassword].
class AwaitingEmailAndPassword extends AuthState {}

/// A state that indicates that user registration is in progress.
/// UIs often reflect this state with a loading indicator.
class SigningUp extends AuthState {}

/// A controller interface of the [EmailAuthFlow].
abstract class EmailAuthController extends AuthController {
  /// Initializes the flow with an email and password. This method should be
  /// called after user submits a form with email and password.
  void setEmailAndPassword(String email, String password);
}

/// {@template ui.auth.flows.email_flow}
/// An auth flow that allows authentication with email and password.
/// {@endtemplate}
class EmailAuthFlow extends AuthFlow<EmailAuthProvider>
    implements EmailAuthController, EmailAuthListener {
  @override
  final EmailAuthProvider provider;

  /// {@macro ui.auth.flows.email_flow}
  EmailAuthFlow({
    /// {@macro ui.auth.auth_flow.ctor.provider}
    required this.provider,

    /// {@macro ui.auth.auth_controller.auth}
    fba.FirebaseAuth? auth,

    /// {@macro @macro ui.auth.auth_action}
    AuthAction? action,
  }) : super(
          action: action,
          initialState: AwaitingEmailAndPassword(),
          auth: auth,
          provider: provider,
        );

  @override
  void onBeforeSignIn() {
    if (action == AuthAction.signUp) {
      value = SigningUp();
    } else {
      super.onBeforeSignIn();
    }
  }

  @override
  void onSignedIn(fba.UserCredential credential) {
    if (action == AuthAction.signUp) {
      value = UserCreated(credential);
    } else {
      super.onSignedIn(credential);
    }
  }

  @override
  void setEmailAndPassword(String email, String password) {
    provider.authenticate(email, password, action);
  }
}
