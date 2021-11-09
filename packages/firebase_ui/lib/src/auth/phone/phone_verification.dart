import 'package:firebase_ui/i10n.dart';
import 'package:flutter/material.dart';

import 'package:firebase_ui/auth.dart';
import 'package:firebase_ui/responsive.dart';

import '../error_text.dart';

Future<void> startPhoneVerification({
  required BuildContext context,
  AuthAction? action,
}) async {
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => _PhoneInputView(action: action),
    ),
  );
}

class _PhoneInputView extends StatelessWidget {
  final AuthAction? action;
  const _PhoneInputView({Key? key, this.action}) : super(key: key);

  void next(BuildContext context, AuthAction? action, Object flowKey) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => _SMSCodeInputView(
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
      appBar: AppBar(
        title: Text(l.phoneVerificationViewTitleText),
      ),
      body: Body(
        child: ResponsiveContainer(
          colWidth: ColWidth(
            phone: 4,
            phablet: 6,
            tablet: 8,
            laptop: 6,
            desktop: 6,
          ),
          child: Center(
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
                    if (state is AwaitingPhoneNumber) ...[
                      PhoneInput(
                        onSubmitted: ctrl.acceptPhoneNumber,
                        key: phoneInputKey,
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () {
                          final number =
                              PhoneInput.getPhoneNumber(phoneInputKey);
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
      ),
    );
  }
}

class _SMSCodeInputView extends StatelessWidget {
  final AuthAction? action;
  final Object? flowKey;

  const _SMSCodeInputView({Key? key, this.action, this.flowKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<SMSCodeInputState>();
    final columnKey = GlobalKey();
    final l = FirebaseUILocalizations.labelsOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.verifyingPhoneNumberViewTitle),
      ),
      body: Body(
        child: ResponsiveContainer(
          colWidth: ColWidth(
            phone: 4,
            phablet: 6,
            tablet: 8,
            laptop: 6,
            desktop: 6,
          ),
          child: Center(
            child: AuthFlowBuilder<PhoneAuthController>(
              action: action,
              flowKey: flowKey,
              listener: (oldState, newState, controller) {
                print(newState);
                if (newState is SignedIn || newState is CredentialLinked) {
                  Navigator.of(context).pop();
                }
              },
              builder: (context, state, ctrl, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  key: columnKey,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SMSCodeInput(key: key),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        ctrl.verifySMSCode(key.currentState!.code);
                      },
                      child: Text(l.verifyCodeButtonText),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
