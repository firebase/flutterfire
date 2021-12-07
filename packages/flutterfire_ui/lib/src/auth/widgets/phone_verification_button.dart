import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/cupertino.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutter/material.dart';
import '../widgets/internal/universal_button.dart';

import '../actions.dart';

class VerifyPhoneAction extends FlutterFireUIAction {
  final void Function(BuildContext context) action;

  VerifyPhoneAction({required this.action});
}

class PhoneVerificationButton extends StatelessWidget {
  final FirebaseAuth? auth;
  final AuthAction? action;
  final String label;

  const PhoneVerificationButton({
    Key? key,
    required this.label,
    this.action,
    this.auth,
  }) : super(key: key);

  void _onPressed(BuildContext context) {
    final navAction = FlutterFireUIAction.ofType<VerifyPhoneAction>(context);
    if (navAction != null) {
      navAction.action(context);
    } else {
      startPhoneVerification(context: context, action: action, auth: auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    return UniversalButton(
      variant: ButtonVariant.text,
      text: label,
      onPressed: () => _onPressed(context),
    );
  }
}
