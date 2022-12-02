// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart' hide Title;

import 'package:firebase_auth/firebase_auth.dart'
    show ActionCodeSettings, FirebaseAuth, FirebaseAuthException;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import '../widgets/internal/universal_button.dart';

import '../widgets/internal/loading_button.dart';
import '../widgets/internal/title.dart';

/// {@template ui.auth.views.forgot_password_view}
/// A view that could be used to build a custom [ForgotPasswordScreen].
/// {@endtemplate}
class ForgotPasswordView extends StatefulWidget {
  /// {@macro ui.auth.auth_controller.auth}
  final FirebaseAuth? auth;

  /// A configuration object that is used to construct a dynamic link.
  final ActionCodeSettings? actionCodeSettings;

  /// Returned widget would be placed under the title.
  final WidgetBuilder? subtitleBuilder;

  /// Returned widget would be placed at the bottom of the view.
  final WidgetBuilder? footerBuilder;

  /// An email that [EmailInput] should be pre-filled with.
  final String? email;

  /// {@macro ui.auth.views.forgot_password_view}
  const ForgotPasswordView({
    Key? key,
    this.auth,
    this.email,
    this.actionCodeSettings,
    this.subtitleBuilder,
    this.footerBuilder,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ForgotPasswordViewState createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final emailCtrl = TextEditingController(text: widget.email ?? '');
  final formKey = GlobalKey<FormState>();
  bool emailSent = false;

  FirebaseAuth get auth => widget.auth ?? FirebaseAuth.instance;
  bool isLoading = false;
  FirebaseAuthException? exception;

  Future<void> _submit(String email) async {
    setState(() {
      exception = null;
      isLoading = true;
    });

    try {
      await auth.sendPasswordResetEmail(
        email: email,
        actionCodeSettings: widget.actionCodeSettings,
      );

      emailSent = true;
    } on FirebaseAuthException catch (e) {
      exception = e;
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);
    const spacer = SizedBox(height: 32);

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Title(text: l.forgotPasswordViewTitle),
          if (!emailSent) ...[
            spacer,
            widget.subtitleBuilder?.call(context) ??
                Text(l.forgotPasswordHintText),
          ],
          spacer,
          if (!emailSent) ...[
            EmailInput(
              autofocus: false,
              controller: emailCtrl,
              onSubmitted: _submit,
            ),
            spacer,
          ] else ...[
            Text(l.passwordResetEmailSentText),
            spacer,
          ],
          if (exception != null) ...[
            const SizedBox(height: 16),
            ErrorText(exception: exception!),
            const SizedBox(height: 16),
          ],
          if (!emailSent)
            LoadingButton(
              isLoading: isLoading,
              label: l.resetPasswordButtonLabel,
              onTap: () {
                if (formKey.currentState!.validate()) {
                  _submit(emailCtrl.text);
                }
              },
            ),
          const SizedBox(height: 8),
          UniversalButton(
            variant: ButtonVariant.text,
            text: l.goBackButtonLabel,
            onPressed: () => Navigator.pop(context),
          ),
          if (widget.footerBuilder != null) widget.footerBuilder!(context),
        ],
      ),
    );
  }
}
