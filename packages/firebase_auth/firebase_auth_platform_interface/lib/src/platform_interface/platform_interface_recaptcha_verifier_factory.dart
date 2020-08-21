// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// A factory platform class for Recaptcha Verifier implementations.
abstract class RecaptchaVerifierFactoryPlatform extends PlatformInterface {
  /// Creates a new [RecaptchaVerifierFactoryPlatform] instance.
  RecaptchaVerifierFactoryPlatform() : super(token: _token);

  static RecaptchaVerifierFactoryPlatform _instance;

  static final Object _token = Object();

  /// Returns an assigned delegate instance.
  ///
  /// On platforms which do not support Recaptcha Verifier, an
  /// [UnimplementedError] will be thrown.
  static RecaptchaVerifierFactoryPlatform get instance {
    if (_instance == null) {
      throw UnimplementedError("RecaptchaVerifier is not implemented");
    }

    return _instance;
  }

  /// Sets a factory delegate as the current [RecaptchaVerifierFactoryPlatform]
  /// instance.
  static set instance(RecaptchaVerifierFactoryPlatform instance) {
    assert(instance != null);

    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Ensures that a delegate class extends [RecaptchaVerifierFactoryPlatform].
  static verifyExtends(RecaptchaVerifierFactoryPlatform instance) {
    assert(instance != null);

    PlatformInterface.verifyToken(instance, _token);
  }

  /// Returns the assigned factory delegate.
  T getDelegate<T>() {
    throw UnimplementedError("getDelegate() is not implemented");
  }

  /// Returns a [RecaptchaVerifierFactoryPlatform] delegate instance.
  ///
  /// Underlying implementations can use this method to create the underlying
  /// implementation of a Recaptcha Verifier.
  RecaptchaVerifierFactoryPlatform delegateFor(
      {String container, Map<String, dynamic> parameters}) {
    throw UnimplementedError("delegateFor() is not implemented");
  }

  /// The application verifier type. For a reCAPTCHA verifier, this is
  /// 'recaptcha'.
  String get type {
    throw UnimplementedError("type is not implemented");
  }

  /// Clears the reCAPTCHA widget from the page and destroys the current
  /// instance.
  void clear() {
    throw UnimplementedError("clear() is not implemented");
  }

  /// Renders the reCAPTCHA widget on the page.
  ///
  /// Returns a Future that resolves with the reCAPTCHA widget ID.
  Future<int> render() async {
    throw UnimplementedError("render() is not implemented");
  }

  /// Waits for the user to solve the reCAPTCHA and resolves with the reCAPTCHA
  /// token.
  Future<String> verify() async {
    throw UnimplementedError("verify() is not implemented");
  }
}
