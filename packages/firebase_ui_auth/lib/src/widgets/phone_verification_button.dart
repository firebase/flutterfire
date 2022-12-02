// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/cupertino.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/internal/universal_button.dart';

/// {@template ui.auth.widgets.phone_verification_button}
/// A button that triggers phone verification flow.
///
/// Triggers a [VerifyPhoneAction] action if provided, otherwise
/// uses [startPhoneVerification].
/// {@endtemplate}
class PhoneVerificationButton extends StatelessWidget {
  /// {@macro ui.auth.auth_controller.auth}
  final FirebaseAuth? auth;

  /// {@macro ui.auth.auth_action}
  final AuthAction? action;

  /// A text that should be displayed on the button.
  final String label;

  /// {@macro ui.auth.widgets.phone_verification_button}
  const PhoneVerificationButton({
    Key? key,
    required this.label,
    this.action,
    this.auth,
  }) : super(key: key);

  void _onPressed(BuildContext context) {
    final a = FirebaseUIAction.ofType<VerifyPhoneAction>(context);

    if (a != null) {
      a.callback(context, action);
    } else {
      startPhoneVerification(context: context, action: action, auth: auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    return UniversalButton(
      variant: ButtonVariant.text,
      text: label,
      onPressed: () => _onPressed(context),
    );
  }
}
