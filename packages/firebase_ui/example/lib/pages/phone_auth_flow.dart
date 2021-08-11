import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui/firebase_ui.dart';
import 'package:flutter/material.dart';

class PhoneAuthFlow extends StatelessWidget {
  final AuthMethod authMethod;

  const PhoneAuthFlow({Key? key, required this.authMethod}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify phone number'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: AuthFlowBuilder<PhoneVerificationController>(
            flow: PhoneVerificationAuthFlow(
              auth: FirebaseAuth.instance,
              method: authMethod,
            ),
            listener: (_, newState) {
              if (newState is SignedIn || newState is CredentialLinked) {
                Navigator.of(context).pop();
              }
            },
            builder: (context, state, ctrl, _) {
              if (state is AwatingPhoneNumber) {
                return TextField(
                  decoration: const InputDecoration(labelText: 'Phone number'),
                  onSubmitted: ctrl.acceptPhoneNumber,
                  autofocus: true,
                  keyboardType: TextInputType.phone,
                );
              }

              if (state is SMSCodeRequested ||
                  state is CredentialReceived ||
                  state is PhoneVerified) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is SMSCodeSent) {
                return TextField(
                  decoration: const InputDecoration(labelText: 'SMS Code'),
                  onSubmitted: ctrl.verifySMSCode,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                );
              }

              return Text('Unknown auth flow state $state');
            },
          ),
        ),
      ),
    );
  }
}
