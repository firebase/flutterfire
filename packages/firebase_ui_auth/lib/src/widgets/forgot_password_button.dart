// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';

import 'internal/universal_button.dart';

/// {@template ui.auth.widget.forgot_password_button}
/// A button that has a localized "Forgot password" label.
/// {@endtemplate}
class ForgotPasswordButton extends StatelessWidget {
  /// A callback that is called when the button is pressed.
  final VoidCallback onPressed;

  /// {@macro ui.auth.widget.forgot_password_button}
  const ForgotPasswordButton({Key? key, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    return UniversalButton(
      variant: ButtonVariant.text,
      text: l.forgotPasswordButtonLabel,
      onPressed: onPressed,
    );
  }
}
