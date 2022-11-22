// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

/// A state that indicates that the sign in link is being sent.
/// UIs often reflect this state with a loading indicator.
class SendingLink extends AuthState {
  const SendingLink();
}

/// A state athat indicates that the sign in link was sent and the user
/// should follow the link from their email to complete the sign in process.
/// UIs often reflect this state with a message that tells the user to follow
/// the link in their email.
class AwaitingDynamicLink extends AuthState {
  const AwaitingDynamicLink();
}

/// A controller interface of the [EmailLinkFlow].
abstract class EmailLinkAuthController extends AuthController {
  /// Sends a sign in link to the [email].
  void sendLink(String email);
}

/// {@template ui.auth.flows.email_link_flow}
/// A flow that implements a sign in flow with a link that is sent to the user's
/// email.
/// {@endtemplate}
class EmailLinkFlow extends AuthFlow<EmailLinkAuthProvider>
    implements EmailLinkAuthController, EmailLinkAuthListener {
  /// {@macro ui.auth.flows.email_link_flow}
  EmailLinkFlow({
    /// {@macro ui.auth.auth_controller.auth}
    FirebaseAuth? auth,

    /// {@macro ui.auth.auth_flow.ctor.provider}
    required EmailLinkAuthProvider provider,
  }) : super(
          action: AuthAction.signIn,
          auth: auth,
          initialState: const Uninitialized(),
          provider: provider,
        );

  @override
  void sendLink(String email) {
    provider.sendLink(email);
  }

  @override
  void onBeforeLinkSent(String email) {
    value = const SendingLink();
  }

  @override
  void onLinkSent(String email) {
    value = const AwaitingDynamicLink();
    provider.awaitLink(email);
  }
}

/// {@template ui.auth.flows.email_link_flow.email_link_sign_in_action}
/// An action that indicates that email link sign in flow was triggered from
/// the UI.
///
/// Could be used to show a [EmailLinkSignInScreen] or trigger a custom
/// logic:
///
/// ```dart
/// SignInScreen(
///   actions: [
///     EmailLinkSignInAction((context) {
///       Navigator.of(context).push(
///         MaterialPageRoute(
///           builder: (context) => EmailLinkSignInScreen(),
///         ),
///       );
///     }),
///   ]
/// );
/// ```
/// {@endtemplate}
class EmailLinkSignInAction extends FirebaseUIAction {
  /// A calback that is being called when a email link sign in flow is triggered
  /// from the UI.
  final void Function(BuildContext context) callback;

  /// {@macro ui.auth.flows.email_link_flow.email_link_sign_in_action}
  EmailLinkSignInAction(this.callback);
}
