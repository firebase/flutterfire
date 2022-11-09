// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterfire_ui/auth.dart';

import '../auth_flow.dart';
import '../auth_state.dart';

class SendingLink extends AuthState {
  const SendingLink();
}

class AwaitingDynamicLink extends AuthState {
  const AwaitingDynamicLink();
}

abstract class EmailLinkFlowController extends AuthController {
  Future<void> sendLink(String email);
}

class EmailLinkFlow extends AuthFlow implements EmailLinkFlowController {
  final ActionCodeSettings actionCodeSettings;
  final FirebaseDynamicLinks? dynamicLinks;

  EmailLinkFlow({
    FirebaseAuth? auth,
    this.dynamicLinks,
    required this.actionCodeSettings,
  }) : super(
          action: AuthAction.signIn,
          auth: auth,
          initialState: const Uninitialized(),
        );

  FirebaseDynamicLinks get _links =>
      dynamicLinks ?? FirebaseDynamicLinks.instance;

  @override
  Future<void> sendLink(String email) async {
    value = const SendingLink();

    try {
      await auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );

      value = const AwaitingDynamicLink();

      final linkData = await _links.onLink.first;
      final link = linkData.link.toString();

      if (auth.isSignInWithEmailLink(link)) {
        value = const SigningIn();
        final userCredential =
            await auth.signInWithEmailLink(email: email, emailLink: link);

        final user = userCredential.user;

        if (user != null) {
          value = SignedIn(user);
        }
      } else {
        throw FirebaseAuthException(
          code: 'invalid-email-signin-link',
          message: 'Invalid email sign in link',
        );
      }
    } on Exception catch (e) {
      value = AuthFailed(e);
    }
  }
}

class EmailLinkSignInAction extends FlutterFireUIAction {
  final void Function(BuildContext context) callback;

  EmailLinkSignInAction(this.callback);
}
