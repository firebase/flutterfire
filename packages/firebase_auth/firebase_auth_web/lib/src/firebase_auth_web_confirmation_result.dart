// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'interop/auth.dart' as auth_interop;
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_web/src/firebase_auth_web_user_credential.dart';
import 'utils/web_utils.dart';

/// The web delegate implementation for [ConfirmationResultPlatform].
class ConfirmationResultWeb extends ConfirmationResultPlatform {
  /// Creates a new [ConfirmationResultWeb] instance.
  ConfirmationResultWeb(this._auth, this._webConfirmationResult)
      : super(_webConfirmationResult.verificationId);

  final FirebaseAuthPlatform _auth;

  final auth_interop.ConfirmationResult _webConfirmationResult;

  @override
  Future<UserCredentialPlatform> confirm(String verificationCode) async {
    try {
      return UserCredentialWeb(
          _auth, await _webConfirmationResult.confirm(verificationCode));
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }
}
