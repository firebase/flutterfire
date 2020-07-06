// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class RecaptchaVerifierFactoryPlatform extends PlatformInterface {
  RecaptchaVerifierFactoryPlatform() : super(token: _token);

  static RecaptchaVerifierFactoryPlatform _instance;

  static final Object _token = Object();

  static RecaptchaVerifierFactoryPlatform get instance {
    if (_instance == null) {
      throw UnimplementedError("RecaptchaVerifier is not implemented");
    }

    return _instance;
  }

  static set instance(RecaptchaVerifierFactoryPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  static verifyExtends(RecaptchaVerifierFactoryPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
  }

  RecaptchaVerifierFactoryPlatform delegateFor({String container, Map<String, dynamic> parameters}) {
    throw UnimplementedError("delegateFor is not implemented");
  }

  String get type {
    throw UnimplementedError("type is not implemented");
  }

  void clear() {
    throw UnimplementedError("clear() is not implemented");
  }

  Future<int> render() async {
    throw UnimplementedError("render() is not implemented");
  }

  Future<String> verify() async {
    throw UnimplementedError("verify() is not implemented");
  }
}
