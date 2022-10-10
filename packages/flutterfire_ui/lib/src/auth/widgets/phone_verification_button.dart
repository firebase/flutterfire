// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/cupertino.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutter/material.dart';
import '../widgets/internal/universal_button.dart';

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
    final _action = FlutterFireUIAction.ofType<VerifyPhoneAction>(context);
    if (_action != null) {
      _action.callback(context, action);
    } else {
      startPhoneVerification(context: context, action: action, auth: auth);
    }
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
