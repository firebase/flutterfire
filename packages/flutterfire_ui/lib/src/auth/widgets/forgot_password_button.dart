import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/i10n.dart';

import 'internal/universal_button.dart';

/// {@template ffui.auth.widget.forgot_password_button}
/// A button that has a localized "Forgot password" label.
/// {@endtemplate}
class ForgotPasswordButton extends StatelessWidget {
  /// A callback that is called when the button is pressed.
  final VoidCallback onPressed;

  /// {@macro ffui.auth.widget.forgot_password_button}
  const ForgotPasswordButton({Key? key, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = FlutterFireUILocalizations.labelsOf(context);

    return UniversalButton(
      variant: ButtonVariant.text,
      text: l.forgotPasswordButtonLabel,
      onPressed: onPressed,
    );
  }
}
