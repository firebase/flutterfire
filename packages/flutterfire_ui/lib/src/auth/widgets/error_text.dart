// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;

import 'package:flutterfire_ui/i10n.dart';

import '../flows/phone_auth_flow.dart';

String? localizedErrorText(
  String? errorCode,
  FlutterFireUILocalizationLabels labels,
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

/// A widget which displays error text for a given Firebase error code.
///
/// {@subCategory service:auth}
/// {@subCategory type:widget}
/// {@subCategory description:A widget which displays error text for a given Firebase error code.}
/// {@subCategory img:https://place-hold.it/400x150}
class ErrorText extends StatelessWidget {
  final Exception exception;
  final TextAlign? textAlign;

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

    final l = FlutterFireUILocalizations.labelsOf(context);
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
