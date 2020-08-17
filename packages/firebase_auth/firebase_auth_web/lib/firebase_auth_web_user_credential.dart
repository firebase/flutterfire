// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';

import 'firebase_auth_web_user.dart';
import 'utils.dart';

/// Web delegate implementation of [UserCredentialPlatform].
class UserCredentialWeb extends UserCredentialPlatform {
  /// Creates a new [UserCredentialWeb] instance.
  UserCredentialWeb(
      FirebaseAuthPlatform auth, firebase.UserCredential webUserCredential)
      : super(
          auth: auth,
          additionalUserInfo: convertWebAdditionalUserInfo(
              webUserCredential.additionalUserInfo),
          credential: convertWebOAuthCredential(webUserCredential.credential),
          user: UserWeb(auth, webUserCredential.user),
        );
}
