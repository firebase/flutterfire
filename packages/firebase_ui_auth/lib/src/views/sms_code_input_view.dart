// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import '../widgets/internal/universal_button.dart';

typedef SMSCodeSubmitCallback = void Function(String smsCode);

/// {@template ui.auth.views.sms_code_input_view}
/// A view that could be used to build a custom [SMSCodeInputScreen].
/// {@endtemplate}
class SMSCodeInputView extends StatefulWidget {
  /// {@macro ui.auth.auth_controller.auth}
  final FirebaseAuth? auth;

  /// {@macro ui.auth.auth_action}
  final AuthAction? action;

  /// A unique object that could be used to obtain an instance of the
  /// [PhoneAuthController].
  final Object flowKey;

  /// A callback that is being called when the code was successfully verified.
  final VoidCallback? onCodeVerified;

  /// A callback that is being called when the user submits a SMS code.
  final SMSCodeSubmitCallback? onSubmit;

  /// {@macro ui.auth.views.sms_code_input_view}
  const SMSCodeInputView({
    Key? key,
    required this.flowKey,
    this.onCodeVerified,
    this.auth,
    this.action,
    this.onSubmit,
  }) : super(key: key);

  @override
  State<SMSCodeInputView> createState() => _SMSCodeInputViewState();
}

class _SMSCodeInputViewState extends State<SMSCodeInputView> {
  final columnKey = GlobalKey();
  final key = GlobalKey<SMSCodeInputState>();

  @override
  void initState() {
    super.initState();

    final state = AuthFlowBuilder.getState(widget.flowKey);

    if (state != null && state is SMSCodeSent) {
      _codeSentState = state;
    }
  }

  SMSCodeSent? _codeSentState;

  void submit(String code, PhoneAuthController ctrl) {
    if (widget.onSubmit != null) {
      widget.onSubmit!(code);
    } else if (_codeSentState != null) {
      ctrl.verifySMSCode(
        code,
        confirmationResult: _codeSentState!.confirmationResult,
        verificationId: _codeSentState!.verificationId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    return AuthFlowBuilder<PhoneAuthController>(
      auth: widget.auth,
      action: widget.action,
      flowKey: widget.flowKey,
      listener: (oldState, newState, controller) {
        if (newState is SignedIn || newState is CredentialLinked) {
          widget.onCodeVerified?.call();
        }

        if (newState is SMSCodeSent) {
          _codeSentState = newState;
        }
      },
      builder: (context, state, ctrl, child) {
        return IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SMSCodeInput(
                key: key,
                onSubmit: (smsCode) {
                  submit(smsCode, ctrl);
                },
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(8),
                child: UniversalButton(
                  onPressed: () {
                    final code = key.currentState!.code;
                    if (code.length < 6) return;
                    submit(code, ctrl);
                  },
                  text: l.verifyCodeButtonText,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
