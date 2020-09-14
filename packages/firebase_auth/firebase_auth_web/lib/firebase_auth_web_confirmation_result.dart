// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_web/firebase_auth_web_user_credential.dart';
import 'package:firebase_auth_web/utils.dart';

/// The web delegate implementation for [ConfirmationResultPlatform].
class ConfirmationResultWeb extends ConfirmationResultPlatform {
  /// Creates a new [ConfirmationResultWeb] instance.
  ConfirmationResultWeb(this._auth, this._webConfirmationResult)
      : super(_webConfirmationResult.verificationId);

  final FirebaseAuthPlatform _auth;

  final firebase.ConfirmationResult _webConfirmationResult;

  @override
  Future<UserCredentialPlatform> confirm(String verificationCode) async {
    try {
      return UserCredentialWeb(
          _auth, await _webConfirmationResult.confirm(verificationCode));
    } catch (e) {
      throw throwFirebaseAuthException(e);
    }
  }
}
