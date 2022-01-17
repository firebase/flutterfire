import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/i10n.dart';
import 'package:flutterfire_ui/src/auth/theme/sign_in_screen_theme.dart';
import '../widgets/internal/universal_text_form_field.dart';

import '../validators.dart';

class EmailInput extends StatelessWidget {
  final FocusNode? focusNode;
  final bool? autofocus;
  final TextEditingController controller;
  final String? initialValue;
  final void Function(String value) onSubmitted;
  final SignInScreenTheme? signInScreenTheme;

  const EmailInput({
    Key? key,
    required this.controller,
    required this.onSubmitted,
    this.focusNode,
    this.autofocus,
    this.initialValue,
    this.signInScreenTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = FlutterFireUILocalizations.labelsOf(context);

    return UniversalTextFormField(
      autofocus: autofocus ?? false,
      focusNode: focusNode,
      controller: controller,
      placeholder: l.emailInputLabel,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      validator: Validator.validateAll([
        NotEmpty(l.emailIsRequiredErrorText),
        EmailValidator(l.isNotAValidEmailErrorText),
      ]),
      onSubmitted: (v) => onSubmitted(v!),
      signInScreenTheme: signInScreenTheme,
    );
  }
}
