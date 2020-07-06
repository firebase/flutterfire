// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class ConfirmationResultPlatform extends PlatformInterface {
  ConfirmationResultPlatform(this.verificationId) : super(token: _token);
  static final Object _token = Object();

  static verifyExtends(ConfirmationResultPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
  }

  final String verificationId;

  Future<UserCredentialPlatform> confirm(String verificationCode) async {
    throw UnimplementedError("confirm() is not implemented");
  }
}
