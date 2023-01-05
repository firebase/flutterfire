// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, MultiFactorSession, PhoneMultiFactorInfo;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/internal/universal_page_route.dart';

/// Opens [PhoneInputScreen].
Future<void> startPhoneVerification({
  required BuildContext context,

  /// {@macro ui.auth.auth_action}
  AuthAction? action,

  /// {@macro ui.auth.auth_controller.auth}
  FirebaseAuth? auth,

  /// {@macro ui.auth.providers.phone_auth_provider.mfa_session}
  MultiFactorSession? multiFactorSession,

  /// {@macro ui.auth.providers.phone_auth_provider.mfa_hint}
  PhoneMultiFactorInfo? hint,

  /// Additional actions to pass down to the [PhoneInputScreen].
  List<FirebaseUIAction> actions = const [],
}) async {
  await Navigator.of(context).push(
    createPageRoute(
      context: context,
      builder: (_) => FirebaseUIActions.inherit(
        from: context,
        actions: actions,
        child: PhoneInputScreen(
          auth: auth,
          action: action,
          multiFactorSession: multiFactorSession,
          mfaHint: hint,
        ),
      ),
    ),
  );
}
