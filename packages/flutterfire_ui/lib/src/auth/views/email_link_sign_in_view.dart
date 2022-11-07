// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart' hide Title;
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/i10n.dart';

import '../widgets/internal/loading_button.dart';
import '../widgets/internal/title.dart';

class EmailLinkSignInView extends StatefulWidget {
  final FirebaseAuth? auth;
  final EmailLinkProviderConfiguration config;
  final FocusNode? emailInputFocusNode;

  const EmailLinkSignInView({
    Key? key,
    this.auth,
    required this.config,
    this.emailInputFocusNode,
  }) : super(key: key);

  @override
  State<EmailLinkSignInView> createState() => _EmailLinkSignInViewState();
}

class _EmailLinkSignInViewState extends State<EmailLinkSignInView> {
  final emailCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final l = FlutterFireUILocalizations.labelsOf(context);

    return AuthFlowBuilder<EmailLinkFlowController>(
      auth: widget.auth,
      config: widget.config,
      builder: (context, state, ctrl, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Title(text: l.signInWithEmailLinkViewTitleText),
            const SizedBox(height: 16),
            if (state is! AwaitingDynamicLink)
              EmailInput(
                autofocus: true,
                focusNode: widget.emailInputFocusNode,
                controller: emailCtrl,
                onSubmitted: ctrl.sendLink,
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
