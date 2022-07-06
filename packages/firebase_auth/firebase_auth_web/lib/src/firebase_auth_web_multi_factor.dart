// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';

/// Web delegate implementation of [UserPlatform].
class MultiFactorWeb extends MultiFactorPlatform {
  MultiFactorWeb(FirebaseAuthPlatform auth) : super(auth);
}
