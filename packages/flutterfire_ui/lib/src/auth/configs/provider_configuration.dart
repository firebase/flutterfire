// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../auth_controller.dart' show AuthAction;
import '../auth_flow.dart';

abstract class ProviderConfiguration {
  const ProviderConfiguration();
  String get providerId;
  AuthFlow createFlow(FirebaseAuth? auth, AuthAction? action);
  bool isSupportedPlatform(TargetPlatform platform);
}
