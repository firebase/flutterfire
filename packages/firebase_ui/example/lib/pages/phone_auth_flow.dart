import 'package:firebase_ui/firebase_ui.dart';
import 'package:firebase_ui/responsive.dart';
import 'package:flutter/material.dart';

class PhoneAuthFlow extends StatelessWidget {
  final AuthAction authMethod;

  const PhoneAuthFlow({Key? key, required this.authMethod}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final phoneInputKey = GlobalKey<PhoneInputState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify phone number'),
      ),
      body: Body(
        child: Center(
          child: ResponsiveContainer(
            colWidth: ColWidth(
              phone: 4,
              phablet: 6,
              tablet: 8,
              laptop: 6,
              desktop: 6,
            ),
            child: AuthFlowBuilder<PhoneVerificationController>(
              action: authMethod,
              config: PhoneProviderConfiguration(),
              listener: (_, newState, __) {
                print('listener $newState');
                if (newState is SignedIn || newState is CredentialLinked) {
                  Navigator.of(context).pop();
                }
              },
              builder: (_, state, ctrl, __) {
                print('builder $state');
                if (state is AwatingPhoneNumber) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                        child: const Text('Verify'),
                      ),
                    ],
                  );
                }

                if (state is SMSCodeRequested || state is CredentialReceived) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is SMSCodeSent || state is PhoneVerified) {
                  final key = GlobalKey<SMSCodeInputState>();
                  return Column(
                    children: [
                      Expanded(child: SMSCodeInput(key: key)),
                      OutlinedButton(
                        onPressed: () {
                          ctrl.verifySMSCode(key.currentState!.code);
                        },
                        child: const Text('Verify the code'),
                      ),
                    ],
                  );
                }

                print('Unknown auth flow state $state');
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }
}
