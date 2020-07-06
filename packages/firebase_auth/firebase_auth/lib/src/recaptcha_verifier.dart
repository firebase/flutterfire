// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_auth;

class RecaptchaVerifier extends RecaptchaVerifierPlatform {
  static final RecaptchaVerifierFactoryPlatform _factory =
      RecaptchaVerifierFactoryPlatform.instance;

  RecaptchaVerifier._(this._delegate) : super(_delegate);

  factory RecaptchaVerifier(
          {String container, Map<String, dynamic> parameters}) =>
      RecaptchaVerifier._(
          _factory.delegateFor(container: container, parameters: parameters));

  // final String container;

  // final Map<String, dynamic> parameters;

  String get type {
    return _delegate.type;
  }

  void clear() {
    return _delegate.clear();
  }

  Future<int> render() async {
    return _delegate.render();
  }

  Future<String> verify() async {
    return _delegate.verify();
  }

  dynamic _delegate;
}
