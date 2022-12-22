// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart' hide Title;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';

import '../widgets/internal/loading_button.dart';
import '../widgets/internal/title.dart';

/// {@template ui.auth.views.email_link_sign_in_view}
/// A view that could be used to build a custom [EmailLinkSignInScreen].
/// {@endtemplate}
class EmailLinkSignInView extends StatefulWidget {
  /// {@macro ui.auth.auth_controller.auth}
  final FirebaseAuth? auth;

  /// An instance of the [EmailLinkAuthProvider] that should be used to
  /// authenticate.
  final EmailLinkAuthProvider provider;

  /// A focus node that could be used to control the focus state of the
  /// [EmailInput].
  final FocusNode? emailInputFocusNode;

  /// {@macro ui.auth.views.email_link_sign_in_view}
  const EmailLinkSignInView({
    Key? key,
    this.auth,
    required this.provider,
    this.emailInputFocusNode,
  }) : super(key: key);

  @override
  State<EmailLinkSignInView> createState() => _EmailLinkSignInViewState();
}

class _EmailLinkSignInViewState extends State<EmailLinkSignInView> {
  final emailCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);
    final formKey = GlobalKey<FormState>();

    return AuthFlowBuilder<EmailLinkAuthController>(
      auth: widget.auth,
      provider: widget.provider,
      builder: (context, state, ctrl, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Title(text: l.signInWithEmailLinkViewTitleText),
            const SizedBox(height: 16),
            if (state is! AwaitingDynamicLink)
              Form(
                key: formKey,
                child: EmailInput(
                  autofocus: true,
                  focusNode: widget.emailInputFocusNode,
                  controller: emailCtrl,
                  onSubmitted: (v) {
                    if (formKey.currentState?.validate() ?? false) {
                      ctrl.sendLink(emailCtrl.text);
                    }
                  },
                ),
              )
            else ...[
              Text(l.signInWithEmailLinkSentText),
              const SizedBox(height: 16),
            ],
            if (state is! AwaitingDynamicLink) ...[
              const SizedBox(height: 8),
              LoadingButton(
                isLoading: state is SendingLink,
                label: l.sendLinkButtonLabel,
                onTap: () {
                  ctrl.sendLink(emailCtrl.text);
                },
              ),
            ],
            const SizedBox(height: 8),
            if (state is AuthFailed) ErrorText(exception: state.exception),
          ],
        );
      },
    );
  }
}
