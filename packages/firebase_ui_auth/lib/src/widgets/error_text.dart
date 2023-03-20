// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
      return labels.credentialAlreadyInUseErrorText;
    case 'invalid-verification-code':
      // TODO(@lesnitsky): localization
      return 'The code you entered is invalid. Please try again.';

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
      color = Theme.of(context).colorScheme.error;
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
