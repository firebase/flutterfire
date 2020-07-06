// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth_platform_interface/src/platform_interface/platform_interface_user.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../../firebase_auth_platform_interface.dart';

abstract class UserCredentialPlatform extends PlatformInterface {
  UserCredentialPlatform(
      {this.auth, this.additionalUserInfo, this.credential, this.user})
      : super(token: _token);

  static final Object _token = Object();

  static verifyExtends(UserCredentialPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
  }

  final FirebaseAuthPlatform auth;

  final AdditionalUserInfo additionalUserInfo;
  final AuthCredential credential;
  final UserPlatform user;
}
