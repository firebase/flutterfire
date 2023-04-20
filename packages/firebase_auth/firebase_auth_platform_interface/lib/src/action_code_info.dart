// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth_platform_interface/src/pigeon/messages.pigeon.dart';
import 'package:meta/meta.dart';

/// A response from calling [checkActionCode].
class ActionCodeInfo {
  // ignore: public_member_api_docs
  @protected
  ActionCodeInfo({
    required this.operation,
    required this.data,
  });

  ActionCodeInfoOperation operation;

  ActionCodeInfoData data;
}

/// The data associated with the action code.
///
/// Depending on the [ActionCodeInfoOperation], `email` and `previousEmail`
/// may be available.
class ActionCodeInfoData {
  // ignore: public_member_api_docs
  @protected
  ActionCodeInfoData({
    required this.email,
    required this.previousEmail,
  });

  /// The email associated with the action code.
  final String? email;

  /// The previous email associated with the action code.
  final String? previousEmail;
}
