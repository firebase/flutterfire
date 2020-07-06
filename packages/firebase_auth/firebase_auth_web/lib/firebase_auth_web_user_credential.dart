// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';

import 'firebase_auth_web_user.dart';
import 'utils.dart';

class UserCredentialWeb extends UserCredentialPlatform {
  UserCredentialWeb(
      FirebaseAuthPlatform auth, firebase.UserCredential webUserCredential)
      : super(
          auth: auth,
          additionalUserInfo: convertWebAdditionalUserInfo(
              webUserCredential.additionalUserInfo),
          credential: null,
          user: UserWeb(auth, webUserCredential.user),
        );
}
