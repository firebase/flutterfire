// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';

import 'internal/universal_button.dart';
import 'internal/universal_page_route.dart';

/// {@template ui.auth.widget.email_link_sign_in_button}
/// A button that starts an email link sign in flow.
///
/// Triggers an [EmailLinkSignInAction] if provided, otherwise
/// opens an [EmailLinkSignInScreen].
///
/// {@endtemplate}
class EmailLinkSignInButton extends StatelessWidget {
  /// {@macro ui.auth.auth_controller.auth}
  final FirebaseAuth? auth;

  /// An instance of [EmailLinkAuthProvider] that should be used to
  /// authenticate.
  final EmailLinkAuthProvider provider;

  /// {@macro ui.auth.widget.email_link_sign_in_button}
  const EmailLinkSignInButton({
    Key? key,
    required this.provider,
    this.auth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;
    final l = FirebaseUILocalizations.labelsOf(context);

    return UniversalButton(
      text: l.emailLinkSignInButtonLabel,
      icon: isCupertino ? CupertinoIcons.link : Icons.link,
      onPressed: () {
        final action = FirebaseUIAction.ofType<EmailLinkSignInAction>(context);
        if (action != null) {
          action.callback(context);
        } else {
          Navigator.of(context).push(
            createPageRoute(
              context: context,
              builder: (_) {
                return FirebaseUIActions.inherit(
                  from: context,
                  child: EmailLinkSignInScreen(
                    auth: auth,
                    provider: provider,
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
