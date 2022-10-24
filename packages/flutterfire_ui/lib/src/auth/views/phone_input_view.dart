// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart' hide Title;
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/i10n.dart';
import '../widgets/internal/universal_button.dart';

import '../widgets/internal/title.dart';

typedef SMSCodeRequestedCallback = void Function(
  BuildContext context,
  AuthAction? action,
  Object flowKey,
  String phoneNumber,
);

typedef PhoneNumberSubmitCallback = void Function(String phoneNumber);

class PhoneInputView extends StatefulWidget {
  final FirebaseAuth? auth;
  final AuthAction? action;
  final Object flowKey;
  final SMSCodeRequestedCallback? onSMSCodeRequested;
  final PhoneNumberSubmitCallback? onSubmit;
  final WidgetBuilder? subtitleBuilder;
  final WidgetBuilder? footerBuilder;

  const PhoneInputView({
    Key? key,
    required this.flowKey,
    this.onSMSCodeRequested,
    this.auth,
    this.action,
    this.onSubmit,
    this.subtitleBuilder,
    this.footerBuilder,
  }) : super(key: key);

  @override
  State<PhoneInputView> createState() => _PhoneInputViewState();
}

class _PhoneInputViewState extends State<PhoneInputView> {
  final phoneInputKey = GlobalKey<PhoneInputState>();

  PhoneNumberSubmitCallback onSubmit(PhoneAuthController ctrl) =>
      (String phoneNumber) {
        if (widget.onSubmit != null) {
          widget.onSubmit!(phoneNumber);
        } else {
          ctrl.acceptPhoneNumber(phoneNumber);
        }
      };

  void _next(PhoneAuthController ctrl) {
    final number = PhoneInput.getPhoneNumber(phoneInputKey);
    if (number != null) {
      onSubmit(ctrl)(number);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = FlutterFireUILocalizations.labelsOf(context);
    final countryCode = Localizations.localeOf(context).countryCode;

    return AuthFlowBuilder<PhoneAuthController>(
      flowKey: widget.flowKey,
      action: widget.action,
      auth: widget.auth,
      listener: (oldState, newState, controller) {
        if (newState is SMSCodeRequested) {
          final cb = widget.onSMSCodeRequested ??
              FlutterFireUIAction.ofType<SMSCodeRequestedAction>(context)
                  ?.callback;

          cb?.call(
            context,
            widget.action,
            widget.flowKey,
            PhoneInput.getPhoneNumber(phoneInputKey)!,
          );
        }
      },
      builder: (context, state, ctrl, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Title(text: l.phoneVerificationViewTitleText),
            const SizedBox(height: 32),
            if (widget.subtitleBuilder != null)
              widget.subtitleBuilder!(context),
            if (state is AwaitingPhoneNumber || state is SMSCodeRequested) ...[
              PhoneInput(
                initialCountryCode: countryCode!,
                onSubmit: onSubmit(ctrl),
                key: phoneInputKey,
              ),
              const SizedBox(height: 16),
              UniversalButton(
                text: l.verifyPhoneNumberButtonText,
                onPressed: () => _next(ctrl),
              ),
            ],
            if (state is AuthFailed) ...[
              const SizedBox(height: 8),
              ErrorText(exception: state.exception),
              const SizedBox(height: 8),
            ],
            if (widget.footerBuilder != null) widget.footerBuilder!(context),
          ],
        );
      },
    );
  }
}
