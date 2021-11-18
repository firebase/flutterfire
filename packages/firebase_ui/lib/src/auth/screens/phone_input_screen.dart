import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:firebase_ui/auth.dart';
import 'package:firebase_ui/i10n.dart';
import 'package:flutter/material.dart';

import 'sms_code_input_screen.dart';

class PhoneInputScreen extends StatelessWidget {
  final AuthAction? action;
  final FirebaseAuth? auth;

  const PhoneInputScreen({
    Key? key,
    this.action,
    this.auth,
  }) : super(key: key);

  void next(BuildContext context, AuthAction? action, Object flowKey) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => SMSCodeInputScreen(
          action: action,
          flowKey: flowKey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final phoneInputKey = GlobalKey<PhoneInputState>();
    final l = FirebaseUILocalizations.labelsOf(context);
    final flowKey = Object();

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: AuthFlowBuilder<PhoneAuthController>(
            flowKey: flowKey,
            action: action,
            listener: (oldState, newState, controller) {
              if (newState is SMSCodeRequested) {
                next(context, action, flowKey);
              }
            },
            builder: (context, state, ctrl, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l.phoneVerificationViewTitleText,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  const SizedBox(height: 16),
                  if (state is AwaitingPhoneNumber) ...[
                    PhoneInput(
                      onSubmitted: ctrl.acceptPhoneNumber,
                      key: phoneInputKey,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () {
                        final number = PhoneInput.getPhoneNumber(phoneInputKey);
                        ctrl.acceptPhoneNumber(number);
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
          ),
        ),
      ),
    );
  }
}
