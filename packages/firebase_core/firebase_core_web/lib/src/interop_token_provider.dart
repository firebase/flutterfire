// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:web/web.dart' as web;

import 'interop/core.dart' as firebase;
import 'interop/utils/es6_interop.dart';

/// Fetches the Auth, App Check and FCM tokens through the internal components
/// the Firebase JS SDK modules register, as the JS Functions SDK does. A null
/// token means the module isn't loaded or has nothing to give, never failure.
class InteropTokenProvider {
  /// Creates a provider over [getComponent]; [notificationsGranted] gates the
  /// Messaging lookup.
  InteropTokenProvider({
    required JSObject? Function(String name) getComponent,
    required bool Function() notificationsGranted,
  }) : _getComponent = getComponent,
       _notificationsGranted = notificationsGranted;

  /// Throws [noAppExists] when there is no app named [appName].
  factory InteropTokenProvider.forApp(String appName) {
    final firebase.AppJsImpl app;
    try {
      app = firebase.app(appName).jsObject;
    } catch (_) {
      throw noAppExists(appName);
    }
    return InteropTokenProvider(
      getComponent: (name) => firebase
          .getProvider(app, name.toJS)
          .getImmediate(firebase.ProviderGetImmediateOptions(optional: true)),
      notificationsGranted: _browserNotificationsGranted,
    );
  }

  final JSObject? Function(String name) _getComponent;
  final bool Function() _notificationsGranted;

  /// The signed-in user's ID token, or null when Auth isn't loaded or nobody is
  /// signed in. Throws `auth-token-failed` when Auth fails.
  Future<String?> getAuthIdToken() async {
    final auth = _getComponent('auth-internal') as _AuthInternal?;
    if (auth == null) {
      return null;
    }
    try {
      final token = await auth.getToken().toDart;
      return token?.accessToken.toDart;
    } catch (error) {
      throw FirebaseException(
        plugin: 'core',
        code: 'auth-token-failed',
        message: _messageOf(error),
      );
    }
  }

  /// App Check's answer, or null until App Check is activated. On failure, the
  /// SDK's placeholder token and the reason.
  Future<AppCheckInteropToken?> getAppCheckToken({
    required bool limitedUse,
  }) async {
    final appCheck = _getComponent('app-check-internal') as _AppCheckInternal?;
    if (appCheck == null) {
      return null;
    }
    try {
      final result =
          await (limitedUse
                  ? appCheck.getLimitedUseToken()
                  : appCheck.getToken())
              .toDart;
      final error = result.error;
      return AppCheckInteropToken(
        token: result.token.toDart,
        error: error == null ? null : (error.message?.toDart ?? '$error'),
      );
    } catch (error) {
      throw FirebaseException(
        plugin: 'core',
        code: 'app-check-token-failed',
        message: _messageOf(error),
      );
    }
  }

  /// The FCM registration token, or null when Messaging isn't loaded, the user
  /// hasn't allowed notifications, or Messaging can't produce one.
  Future<String?> getMessagingToken() async {
    // Messaging's getToken() prompts while permission is undecided.
    if (!_notificationsGranted()) {
      return null;
    }
    final messaging =
        _getComponent('messaging-internal') as _MessagingInternal?;
    if (messaging == null) {
      return null;
    }
    try {
      return (await messaging.getToken().toDart).toDart;
    } catch (_) {
      // The JS Functions SDK sends no token when Messaging fails.
      return null;
    }
  }
}

/// Whether the page may show notifications, without asking the user.
bool _browserNotificationsGranted() =>
    globalContext.has('Notification') &&
    web.Notification.permission == 'granted';

/// The message of a JS error thrown by an SDK, or the error itself otherwise.
String _messageOf(Object error) {
  // isA on Object requires Dart 3.12; this package supports 3.10.
  // ignore: invalid_runtime_check_with_js_interop_types
  if (error is JSError) {
    final message = error.message?.toDart;
    if (message != null) {
      return message;
    }
  }
  return '$error';
}

/// `auth-internal`, Auth's internal component.
extension type _AuthInternal._(JSObject _) implements JSObject {
  /// Resolves to null when nobody is signed in.
  external JSPromise<_AuthToken?> getToken();
}

extension type _AuthToken._(JSObject _) implements JSObject {
  external JSString get accessToken;
}

/// `app-check-internal`, App Check's internal component.
extension type _AppCheckInternal._(JSObject _) implements JSObject {
  external JSPromise<_AppCheckTokenResult> getToken();

  external JSPromise<_AppCheckTokenResult> getLimitedUseToken();
}

extension type _AppCheckTokenResult._(JSObject _) implements JSObject {
  /// The token, or App Check's placeholder when [error] is set.
  external JSString get token;

  external _ErrorLike? get error;
}

extension type _ErrorLike._(JSObject _) implements JSObject {
  external JSString? get message;
}

/// `messaging-internal`, Messaging's internal component.
extension type _MessagingInternal._(JSObject _) implements JSObject {
  external JSPromise<JSString> getToken();
}
