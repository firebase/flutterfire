// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';

class RecaptchaVerifierFactoryWeb extends RecaptchaVerifierFactoryPlatform {
  firebase.RecaptchaVerifier _delegate;

  static RecaptchaVerifierFactoryWeb get instance =>
      RecaptchaVerifierFactoryWeb();

  RecaptchaVerifierFactoryWeb(
      {String container, Map<String, dynamic> parameters})
      : _delegate = firebase.RecaptchaVerifier(container, parameters),
        super();

  @override
  RecaptchaVerifierFactoryPlatform delegateFor(
      {String container, Map<String, dynamic> parameters}) {
    return RecaptchaVerifierFactoryWeb(
        container: container, parameters: parameters);
  }

  @override
  String get type => _delegate.type;

  @override
  void clear() {
    return _delegate.clear();
  }

  @override
  Future<String> verify() {
    return _delegate.verify();
  }

  @override
  Future<int> render() {
    return _delegate.render();
  }
}
