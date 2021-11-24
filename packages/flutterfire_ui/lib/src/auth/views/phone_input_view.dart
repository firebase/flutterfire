import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/i10n.dart';
import 'package:flutter/material.dart';

import '../auth_controller.dart';
import '../widgets/auth_flow_builder.dart';
import '../flows/phone_auth_flow.dart';

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

  const PhoneInputView({
    Key? key,
    required this.flowKey,
    this.onSMSCodeRequested,
    this.auth,
    this.action,
    this.onSubmit,
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

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    return AuthFlowBuilder<PhoneAuthController>(
      flowKey: widget.flowKey,
      action: widget.action,
      auth: widget.auth,
      listener: (oldState, newState, controller) {
        if (newState is SMSCodeRequested) {
          widget.onSMSCodeRequested!(
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
            Text(
              l.phoneVerificationViewTitleText,
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 32),
            if (state is AwaitingPhoneNumber || state is SMSCodeRequested) ...[
              PhoneInput(
                onSubmit: onSubmit(ctrl),
                key: phoneInputKey,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  final number = PhoneInput.getPhoneNumber(phoneInputKey);
                  if (number != null) {
                    onSubmit(ctrl)(number);
                  }
                },
                child: Text(l.verifyPhoneNumberButtonText),
              ),
            ],
            if (state is AuthFailed) ...[
              const SizedBox(height: 8),
              ErrorText(exception: state.exception)
            ],
          ],
        );
      },
    );
  }
}
