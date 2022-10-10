// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/i10n.dart';

import 'internal/universal_button.dart';

class ForgotPasswordButton extends StatelessWidget {
  final VoidCallback onPressed;
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
