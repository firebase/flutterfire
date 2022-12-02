// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart' hide Title;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import '../widgets/internal/universal_button.dart';

import '../widgets/internal/title.dart';

typedef SMSCodeRequestedCallback = void Function(
  BuildContext context,
  AuthAction? action,
  Object flowKey,
  String phoneNumber,
);

typedef PhoneNumberSubmitCallback = void Function(String phoneNumber);

/// {@template ui.auth.views.phone_input_view}
/// A view that could be used to build a custom [PhoneInputScreen].
/// {@endtemplate}
class PhoneInputView extends StatefulWidget {
  /// {@macro ui.auth.auth_controller.auth}
  final FirebaseAuth? auth;

  /// {@macro ui.auth.auth_action}
  final AuthAction? action;

  /// A unique object that could be used to obtain an instance of the
  /// [PhoneAuthController].
  final Object flowKey;

  /// A callback that is being called when the SMS code was requested.
  final SMSCodeRequestedCallback? onSMSCodeRequested;

  /// A callback that is being called when the user submits a phone number.
  final PhoneNumberSubmitCallback? onSubmit;

  /// Returned widget would be placed under the title.
  final WidgetBuilder? subtitleBuilder;

  /// Returned widget would be placed at the bottom.
  final WidgetBuilder? footerBuilder;

  /// {@macro ui.auth.providers.phone_auth_provider.mfa_session}
  final MultiFactorSession? multiFactorSession;

  /// {@macro ui.auth.providers.phone_auth_provider.mfa_hint}
  final PhoneMultiFactorInfo? mfaHint;

  /// {@macro ui.auth.views.phone_input_view}
  const PhoneInputView({
    Key? key,
    required this.flowKey,
    this.onSMSCodeRequested,
    this.auth,
    this.action,
    this.onSubmit,
    this.subtitleBuilder,
    this.footerBuilder,
    this.multiFactorSession,
    this.mfaHint,
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
          ctrl.acceptPhoneNumber(
            phoneNumber,
            widget.multiFactorSession,
          );
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
    final l = FirebaseUILocalizations.labelsOf(context);
    final countryCode = Localizations.localeOf(context).countryCode ??
        WidgetsBinding.instance.platformDispatcher.locale.countryCode;

    return AuthFlowBuilder<PhoneAuthController>(
      flowKey: widget.flowKey,
      action: widget.action,
      auth: widget.auth,
      listener: (oldState, newState, controller) {
        if (newState is SMSCodeRequested) {
          final cb = widget.onSMSCodeRequested ??
              FirebaseUIAction.ofType<SMSCodeRequestedAction>(context)
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
                initialCountryCode: countryCode,
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
