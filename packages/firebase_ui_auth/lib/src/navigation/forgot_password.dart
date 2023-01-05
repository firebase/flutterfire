// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import '../widgets/internal/universal_page_route.dart';

/// Opens a [ForgotPasswordScreen].
Future<void> showForgotPasswordScreen({
  required BuildContext context,

  /// {@macro ui.auth.auth_controller.auth}
  FirebaseAuth? auth,

  /// A email that requires password reset.
  String? email,

  /// A returned widget would be placed under the title of the screen.
  WidgetBuilder? subtitleBuilder,

  /// A returned widget would be placed at the bottom.
  WidgetBuilder? footerBuilder,
}) async {
  final route = createPageRoute(
    context: context,
    builder: (_) => FirebaseUIActions.inherit(
      from: context,
      child: ForgotPasswordScreen(
        auth: auth,
        email: email,
        footerBuilder: footerBuilder,
        subtitleBuilder: subtitleBuilder,
      ),
    ),
  );

  await Navigator.of(context).push(route);
}
