// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_auth;

/// An [reCAPTCHA](https://www.google.com/recaptcha/?authuser=0)-based
/// application verifier.
class RecaptchaVerifier {
  static final RecaptchaVerifierFactoryPlatform _factory =
      RecaptchaVerifierFactoryPlatform.instance;

  RecaptchaVerifier._(this._delegate);

  RecaptchaVerifierFactoryPlatform _delegate;

  /// Creates a new [RecaptchaVerifier] instance.
  ///
  /// [container] This has different meaning depending on whether the reCAPTCHA
  ///  is hidden or visible. For a visible reCAPTCHA the container must be
  ///  empty. If a string is used, it has to correspond to an element ID. The
  ///  corresponding element must also must be in the DOM at the time of
  ///  initialization.
  ///
  /// [parameters] Check the reCAPTCHA docs for a comprehensive list. All
  ///  parameters are accepted except for the site key. Firebase Auth backend
  ///  provisions a reCAPTCHA for each project and will configure this upon
  ///  rendering. For an invisible reCAPTCHA, a size key must have the value
  ///  'invisible'.
  factory RecaptchaVerifier(
          {String container, Map<String, dynamic> parameters}) =>
      RecaptchaVerifier._(
          _factory.delegateFor(container: container, parameters: parameters));

  /// Returns the underlying factory delegate instance.
  @protected
  RecaptchaVerifierFactoryPlatform get delegate {
    return _delegate;
  }

  /// The application verifier type. For a reCAPTCHA verifier, this is
  /// 'recaptcha'.
  String get type {
    return _delegate.type;
  }

  /// Clears the reCAPTCHA widget from the page and destroys the current
  /// instance.
  void clear() {
    return _delegate.clear();
  }

  /// Renders the reCAPTCHA widget on the page.
  ///
  /// Returns a [Future] that resolves with the reCAPTCHA widget ID.
  Future<int> render() async {
    return _delegate.render();
  }

  /// Waits for the user to solve the reCAPTCHA and resolves with the reCAPTCHA
  /// token.
  Future<String> verify() async {
    return _delegate.verify();
  }
}
