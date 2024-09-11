// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:js_interop';

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:web/web.dart' as web;

import 'interop/auth.dart' as auth_interop;
import 'utils/web_utils.dart';

const String _kInvisibleElementId = '__ff-recaptcha-container';

/// The delegate implementation for [RecaptchaVerifierFactoryPlatform].
///
/// This factory class is implemented to the user facing code has no underlying knowledge
/// of the delegate implementation.
class RecaptchaVerifierFactoryWeb extends RecaptchaVerifierFactoryPlatform {
  late auth_interop.RecaptchaVerifier _delegate;

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
  RecaptchaVerifierFactoryWeb({
    required FirebaseAuthWeb auth,
    String? container,
    RecaptchaVerifierSize size = RecaptchaVerifierSize.normal,
    RecaptchaVerifierTheme theme = RecaptchaVerifierTheme.light,
    RecaptchaVerifierOnSuccess? onSuccess,
    RecaptchaVerifierOnError? onError,
    RecaptchaVerifierOnExpired? onExpired,
  }) : super() {
    String element;
    Map<String, JSAny> parameters = {};

    if (onSuccess != null) {
      parameters['callback'] = ((JSObject resp) {
        onSuccess();
      }).toJS;
    }

    if (onExpired != null) {
      parameters['expired-callback'] = (() {
        onExpired();
      }).toJS;
    }

    if (onError != null) {
      parameters['error-callback'] = ((JSObject error) {
        onError(getFirebaseAuthException(error));
      }).toJS;
    }

    if (container == null || container.isEmpty) {
      parameters['size'] = 'invisible'.toJS;
      web.Element? el =
          web.window.document.getElementById(_kInvisibleElementId);

      // If an existing element exists, something may have already been rendered.
      if (el != null) {
        el.remove();
      }

      final documentElement = web.window.document.documentElement;

      if (documentElement == null) {
        throw StateError('No document element found');
      }

      final childElement = web.window.document.createElement('div');
      childElement.id = _kInvisibleElementId;

      documentElement.appendChild(childElement);

      element = _kInvisibleElementId;
    } else {
      parameters['size'] = convertRecaptchaVerifierSize(size).toJS;
      parameters['theme'] = convertRecaptchaVerifierTheme(theme).toJS;

      assert(
        web.window.document.getElementById(container) != null,
        'An exception was thrown whilst creating a RecaptchaVerifier instance. No DOM element with an ID of $container could be found.',
      );

      // If the provided string container ID has been found, assign it.
      element = container;
    }

    _delegate = auth_interop.RecaptchaVerifier(
      element.toJS,
      parameters,
      auth.delegate,
    );
  }

  @override
  RecaptchaVerifierFactoryPlatform delegateFor({
    required FirebaseAuthPlatform auth,
    String? container,
    RecaptchaVerifierSize size = RecaptchaVerifierSize.normal,
    RecaptchaVerifierTheme theme = RecaptchaVerifierTheme.light,
    RecaptchaVerifierOnSuccess? onSuccess,
    RecaptchaVerifierOnError? onError,
    RecaptchaVerifierOnExpired? onExpired,
  }) {
    final _webAuth = auth as FirebaseAuthWeb;
    return RecaptchaVerifierFactoryWeb(
      auth: _webAuth,
      container: container,
      size: size,
      theme: theme,
      onSuccess: onSuccess,
      onError: onError,
      onExpired: onExpired,
    );
  }

  @override
  auth_interop.ApplicationVerifier get delegate {
    return _delegate;
  }

  @override
  String get type => _delegate.type;

  @override
  void clear() {
    _delegate.clear();
    web.window.document.getElementById(_kInvisibleElementId)?.remove();
  }

  @override
  Future<String> verify() {
    try {
      return _delegate.verify();
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }

  @override
  Future<int> render() async {
    try {
      return await _delegate.render();
    } catch (e) {
      throw getFirebaseAuthException(e);
    }
  }
}
