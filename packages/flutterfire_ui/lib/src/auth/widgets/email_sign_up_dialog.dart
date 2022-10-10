// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide Title;
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/i10n.dart';

import 'internal/title.dart';

class EmailSignUpDialog extends StatelessWidget {
  final FirebaseAuth? auth;
  final AuthAction? action;
  final EmailProviderConfiguration config;

  const EmailSignUpDialog({
    Key? key,
    this.auth,
    required this.config,
    required this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = FlutterFireUILocalizations.labelsOf(context);

    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Dialog(
            child: AuthStateListener<EmailFlowController>(
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
                      config: config,
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
