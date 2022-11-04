// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/src/auth/auth_flow.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailLinkProviderConfiguration extends ProviderConfiguration {
  final ActionCodeSettings actionCodeSettings;
  final FirebaseDynamicLinks? dynamicLinks;

  const EmailLinkProviderConfiguration({
    required this.actionCodeSettings,
    this.dynamicLinks,
  });

  @override
  AuthFlow createFlow(FirebaseAuth? auth, AuthAction? action) {
    return EmailLinkFlow(
      auth: auth,
      actionCodeSettings: actionCodeSettings,
      dynamicLinks: dynamicLinks,
    );
  }

  @override
  bool isSupportedPlatform(TargetPlatform platform) {
    return !kIsWeb &&
        (platform == TargetPlatform.android || platform == TargetPlatform.iOS);
  }

  @override
  String get providerId => 'email_link';
}
