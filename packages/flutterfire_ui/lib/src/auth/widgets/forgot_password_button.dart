import 'package:flutter/material.dart';
import 'package:flutterfire_ui/i10n.dart';

class ForgotPssswordButton extends StatelessWidget {
  final VoidCallback onPressed;
  const ForgotPssswordButton({Key? key, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    return TextButton(
      onPressed: onPressed,
      child: Text(l.forgotPasswordButtonLabel),
    );
  }
}
