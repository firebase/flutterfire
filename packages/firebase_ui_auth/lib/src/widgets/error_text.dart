import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;

import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';

import '../flows/phone_auth_flow.dart';

String? localizedErrorText(
  String? errorCode,
  FirebaseUILocalizationLabels labels,
) {
  switch (errorCode) {
    case 'user-not-found':
      return labels.userNotFoundErrorText;
    case 'email-already-in-use':
      return labels.emailTakenErrorText;
    case 'too-many-requests':
      return labels.accessDisabledErrorText;
    case 'wrong-password':
      return labels.wrongOrNoPasswordErrorText;
    case 'credential-already-in-use':
      // TODO(lesnitsky): add translation
      return 'This credential is already associated with a different user account.';

    default:
      return null;
  }
}

/// {@template ui.auth.widgets.error_text}
/// A widget which displays error text for a given Firebase error code.
/// {@endtemplate}
class ErrorText extends StatelessWidget {
  /// An exception that contains error details.
  /// Often this is a [FirebaseAuthException].
  final Exception exception;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// {@macro ui.auth.widgets.error_text}
  const ErrorText({
    Key? key,
    required this.exception,
    this.textAlign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late Color color;
    final isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;

    if (isCupertino) {
      color = CupertinoColors.destructiveRed;
    } else {
      color = Theme.of(context).errorColor;
    }

    final l = FirebaseUILocalizations.labelsOf(context);
    String text = l.unknownError;

    if (exception is AutoresolutionFailedException) {
      text = l.smsAutoresolutionFailedError;
    }

    if (exception is FirebaseAuthException) {
      final e = exception as FirebaseAuthException;
      final code = e.code;
      final newText = localizedErrorText(code, l) ?? e.message;

      if (newText != null) {
        text = newText;
      }
    }

    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(color: color),
    );
  }
}
