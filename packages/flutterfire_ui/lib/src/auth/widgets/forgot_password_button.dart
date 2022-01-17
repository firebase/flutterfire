import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/i10n.dart';
import 'package:flutterfire_ui/src/auth/theme/sign_in_screen_theme.dart';

import 'internal/universal_button.dart';

class ForgotPasswordButton extends StatelessWidget {
  final VoidCallback onPressed;
  final SignInScreenTheme? signInScreenTheme;
  const ForgotPasswordButton({Key? key, required this.onPressed, this.signInScreenTheme})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = FlutterFireUILocalizations.labelsOf(context);

    return UniversalButton(
      variant: ButtonVariant.text,
      text: l.forgotPasswordButtonLabel,
      onPressed: onPressed,
      signInScreenTheme: signInScreenTheme,
    );
  }
}
