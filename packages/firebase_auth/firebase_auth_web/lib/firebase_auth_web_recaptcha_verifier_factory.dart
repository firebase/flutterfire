// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_web/utils.dart';

/// The delegate implementation for [RecaptchaVerifierFactoryPlatform].
///
/// This factory class is implemented to the user facing code has no underlying knowledge
/// of the delegate implementation.
class RecaptchaVerifierFactoryWeb extends RecaptchaVerifierFactoryPlatform {
  firebase.RecaptchaVerifier _delegate;

  /// Returns a stub instance of the class.
  ///
  /// This is used during initialization of the plugin so the user-facing
  /// code has access to the class instance without directly knowing about it.
  ///
  /// See the [registerWith] static method on the [FirebaseAuthWeb] class.
  static RecaptchaVerifierFactoryWeb get instance =>
      RecaptchaVerifierFactoryWeb._();

  RecaptchaVerifierFactoryWeb._() : super();

  /// Creates a new [RecaptchaVerifierFactoryWeb] with a container and parameters.
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
  T getDelegate<T>() {
    return _delegate as T;
  }

  @override
  String get type => _delegate.type;

  @override
  void clear() {
    return _delegate.clear();
  }

  @override
  Future<String> verify() {
    try {
      return _delegate.verify();
    } catch (e) {
      throw throwFirebaseAuthException(e);
    }
  }

  @override
  Future<int> render() {
    try {
      return _delegate.render();
    } catch (e) {
      throw throwFirebaseAuthException(e);
    }
  }
}
