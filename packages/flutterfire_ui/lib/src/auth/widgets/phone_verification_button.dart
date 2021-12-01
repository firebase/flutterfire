import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/cupertino.dart';
import 'package:flutterfire_ui/auth.dart' hide ButtonVariant;
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/src/auth/widgets/internal/universal_button.dart';

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
    startPhoneVerification(context: context, action: action, auth: auth);
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
