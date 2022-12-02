// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide Title;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';

import 'internal/title.dart';
import 'internal/universal_button.dart';

/// {@template ui.auth.widgets.reauthenticate_dialog}
/// A dialog that prompts the user to re-authenticate their account
/// Used to confirm destructive actions (like account deletion or disabling MFA).
/// {@endtemplate}
class ReauthenticateDialog extends StatelessWidget {
  /// {@macro ui.auth.auth_controller.auth}
  final FirebaseAuth? auth;

  /// A list of all supported auth providers.
  final List<AuthProvider> providers;

  /// A callback that is being called when the user has successfully signed in.
  final VoidCallback? onSignedIn;

  /// A label that would be used for the "Sign in" button.
  final String? actionButtonLabelOverride;

  /// {@macro ui.auth.widgets.reauthenticate_dialog}
  const ReauthenticateDialog({
    Key? key,
    required this.providers,
    this.auth,
    this.onSignedIn,
    this.actionButtonLabelOverride,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    const verticalPadding = EdgeInsets.symmetric(vertical: 16);
    const horizontalPadding = EdgeInsets.symmetric(horizontal: 16);

    final reauthenticateView = ReauthenticateView(
      auth: auth,
      providers: providers,
      onSignedIn: onSignedIn,
      actionButtonLabelOverride: actionButtonLabelOverride,
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Dialog(
          child: Padding(
            padding: verticalPadding,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: horizontalPadding,
                      child: Title(text: l.verifyItsYouText),
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: constraints.maxHeight < 500
                            ? 300
                            : constraints.maxHeight,
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          reauthenticateView,
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    Padding(
                      padding: horizontalPadding.copyWith(
                        top: verticalPadding.top,
                      ),
                      child: UniversalButton(
                        text: l.cancelLabel,
                        variant: ButtonVariant.text,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
