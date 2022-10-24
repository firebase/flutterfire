// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

import '../widgets/internal/universal_page_route.dart';

Future<void> showForgotPasswordScreen({
  required BuildContext context,
  FirebaseAuth? auth,
  String? email,
  WidgetBuilder? subtitleBuilder,
  WidgetBuilder? footerBuilder,
}) async {
  final route = createPageRoute(
    context: context,
    builder: (_) => FlutterFireUIActions.inherit(
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
