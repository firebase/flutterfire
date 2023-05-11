// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_shared/firebase_ui_shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/material.dart';

/// {@template ui.auth.widgets.sign_out_button}
/// A button that signs out the user when pressed.
/// {@endtemplate}
class SignOutButton extends StatelessWidget {
  /// {@macro ui.auth.auth_controller.auth}
  final FirebaseAuth? auth;

  /// {@macro ui.shared.widgets.button_variant}
  final ButtonVariant variant;

  /// {@macro ui.auth.widgets.sign_out_button}
  const SignOutButton({
    super.key,
    this.auth,
    this.variant = ButtonVariant.filled,
  });

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    return UniversalButton(
      text: l.signOutButtonText,
      onPressed: () => FirebaseUIAuth.signOut(
        context: context,
        auth: auth,
      ),
      cupertinoIcon: CupertinoIcons.arrow_right_circle,
      materialIcon: Icons.logout,
      variant: variant,
    );
  }
}
