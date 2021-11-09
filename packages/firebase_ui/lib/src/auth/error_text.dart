import 'package:flutter/material.dart';

import 'package:firebase_ui/i10n.dart';

import 'phone/phone_auth_flow.dart';

class ErrorText extends StatelessWidget {
  final Exception exception;
  const ErrorText({Key? key, required this.exception}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).errorColor;
    final l = FirebaseUILocalizations.labelsOf(context);
    String text = l.unknownError;

    if (exception is AutoresolutionFailedException) {
      text = l.smsAutoresolutionFailedError;
    }

    return Text(text, style: TextStyle(color: color));
  }
}
