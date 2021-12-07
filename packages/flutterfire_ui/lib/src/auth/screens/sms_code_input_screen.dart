import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/i10n.dart';
import '../auth_flow.dart';
import '../widgets/internal/universal_button.dart';

import '../widgets/internal/universal_scaffold.dart';

/// A screen displaying a UI which allows users to enter an SMS validation code
/// sent from Firebase.
///
/// {@subCategory service:auth}
/// {@subCategory type:screen}
/// {@subCategory description:A screen displaying SMS verification UI.}
/// {@subCategory img:https://place-hold.it/400x150}
class SMSCodeInputScreen extends StatelessWidget {
  final AuthAction? action;
  final FirebaseAuth? auth;
  final Object flowKey;

  const SMSCodeInputScreen({
    Key? key,
    this.action,
    this.auth,
    required this.flowKey,
  }) : super(key: key);

  void _reset() {
    final ctrl = AuthFlowBuilder.getController<PhoneAuthController>(flowKey);
    ctrl?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final l = FlutterFireUILocalizations.labelsOf(context);

    return WillPopScope(
      onWillPop: () async {
        _reset();
        return true;
      },
      child: UniversalScaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SMSCodeInputView(
                  auth: auth,
                  action: action,
                  flowKey: flowKey,
                  onCodeVerified: () {
                    Navigator.of(context).popUntil((route) {
                      return route.isFirst;
                    });
                  },
                ),
                UniversalButton(
                  variant: ButtonVariant.text,
                  text: l.goBackButtonLabel,
                  onPressed: () {
                    _reset();
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
