import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;

import 'package:firebase_ui/auth.dart';
import 'package:firebase_ui/i10n.dart';
import 'package:flutter/material.dart';

import '../../responsive.dart';
import '../auth_controller.dart';

class SMSCodeInputScreen extends StatelessWidget {
  final AuthAction? action;
  final FirebaseAuth? auth;
  final Object? flowKey;

  const SMSCodeInputScreen({
    Key? key,
    this.action,
    this.auth,
    this.flowKey,
  }) : super(key: key);

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
              auth: auth,
              action: action,
              flowKey: flowKey,
              listener: (oldState, newState, controller) {
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
