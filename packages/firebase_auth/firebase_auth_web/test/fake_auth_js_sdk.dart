// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

/// Makes `Firebase.app()` return an app without `Firebase.initializeApp()`,
/// so `FirebaseAuthWeb.instance` can be used in tests.
class FakeFirebase extends FirebasePlatform {
  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return FirebaseAppPlatform(
      name,
      const FirebaseOptions(
        apiKey: 'api-key',
        appId: 'app-id',
        messagingSenderId: 'sender-id',
        projectId: 'project-id',
      ),
    );
  }
}

/// A JS `Error`. With a [code], it is shaped like the `FirebaseError` the
/// Auth JS SDK throws.
JSObject jsError(String message, {String? code}) {
  final error = globalContext
      .getProperty<JSFunction>('Error'.toJS)
      .callAsConstructor<JSObject>(message.toJS);
  if (code != null) {
    error['name'] = 'FirebaseError'.toJS;
    error['code'] = code.toJS;
  }
  return error;
}

/// A JS promise that rejects with [error].
JSPromise rejectWith(JSAny error) => globalContext
    .getProperty<JSObject>('Promise'.toJS)
    .callMethod<JSPromise>('reject'.toJS, error);

/// A JS promise that resolves with [value].
JSPromise resolveWith(JSAny? value) => globalContext
    .getProperty<JSObject>('Promise'.toJS)
    .callMethod<JSPromise>('resolve'.toJS, value);

/// A JS function that returns [instance] when called with `new`.
JSFunction jsConstructor(JSObject instance) => globalContext
    .getProperty<JSFunction>('Function'.toJS)
    .callAsConstructor<JSFunction>(
      'instance'.toJS,
      'return function () { return instance; };'.toJS,
    )
    // `callMethod` drops arguments after the first `null`, so pass a `this`.
    .callMethod<JSFunction>('call'.toJS, globalContext, instance);

/// Installs the parts of the `firebase_core` and `firebase_auth` JS SDKs that
/// `FirebaseAuthWeb.delegate` needs, and returns the `firebase_auth` object so
/// a test can add the functions it calls.
JSObject stubFirebaseAuthJsSdk() {
  final core = JSObject();
  core['getApp'] = (([JSAny? name]) => JSObject()).toJS;
  globalContext['firebase_core'] = core;

  // getFirebaseAuthException always calls OAuthProvider.credentialFromError.
  final oauthProvider = JSObject();
  oauthProvider['credentialFromError'] = ((JSAny _) => null).toJS;

  final auth = JSObject();
  for (final name in [
    'indexedDBLocalPersistence',
    'browserLocalPersistence',
    'browserSessionPersistence',
    'debugErrorMap',
    'browserPopupRedirectResolver',
  ]) {
    auth[name] = JSObject();
  }
  auth['OAuthProvider'] = oauthProvider;
  auth['initializeAuth'] = ((JSAny? app, JSAny? options) => JSObject()).toJS;
  globalContext['firebase_auth'] = auth;
  return auth;
}
