// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutterfire_ui/auth.dart';
import 'package:flutter/material.dart';

import '../widgets/internal/universal_page_route.dart';

Future<void> startPhoneVerification({
  required BuildContext context,
  AuthAction? action,
  FirebaseAuth? auth,
}) async {
  await Navigator.of(context).push(
    createPageRoute(
      context: context,
      builder: (_) => FlutterFireUIActions.inherit(
        from: context,
        child: PhoneInputScreen(action: action),
      ),
    ),
  );
}
