// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/material.dart' hide Title;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';

import 'internal/title.dart';

/// {@template ui.auth.widget.email_sign_up_dialog}
/// A dialog [Widget] that allows to create a new account using email and
/// password or to link current account with an email.
/// {@endtemplate}
class EmailSignUpDialog extends StatelessWidget {
  /// {@macro ui.auth.auth_controller.auth}
  final FirebaseAuth? auth;

  /// {@macro ui.auth.auth_action}
  final AuthAction? action;

  /// An instance of [EmailAuthProvider] that should be used to authenticate.
  final EmailAuthProvider provider;

  /// {@macro ui.auth.widget.email_sign_up_dialog}
  const EmailSignUpDialog({
    Key? key,
    this.auth,
    required this.provider,
    required this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Dialog(
            child: AuthStateListener<EmailAuthController>(
              listener: (oldState, newState, ctrl) {
                if (newState is CredentialLinked) {
                  Navigator.of(context).pop();
                }

                return null;
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16),
                    Title(text: l.provideEmail),
                    const SizedBox(height: 32),
                    EmailForm(
                      auth: auth,
                      action: action,
                      provider: provider,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
