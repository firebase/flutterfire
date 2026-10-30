// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:developer' as developer;

import 'package:dart_cloud_functions/src/context.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Gets each request's tokens from the Firebase services of [app].
///
/// The ID token comes from `FirebaseAuth.instanceFor(app: app)`, not from
/// `app.getService<FirebaseAuth>()` as in `firebase_ai`. The service is only
/// registered once the app has used `FirebaseAuth`, so a call made before
/// that would go out without the token of a user restored from a previous
/// launch.
///
/// The App Check token comes from `app.getService<FirebaseAppCheck>()`. That
/// service is registered when the app sets up App Check, so apps that don't
/// use it never ask for a token. Both tokens are fetched at the same time, as
/// in the native SDKs.
///
/// When fetching a token fails, each platform follows the SDK that
/// `cloud_functions` uses there: the native SDKs on Android and Apple, and the
/// JS SDK on web. See [idTokenOrNullOnWeb] and [appCheckTokenOrFallback].
CallableContextProvider firebaseCallableContext(FirebaseApp app) {
  return ({required limitedUseAppCheckToken}) async {
    // Start both fetches before awaiting either, so they run at the same time.
    // App Check never fails, so an Auth failure leaves no error unhandled.
    final authToken = _idToken(app);
    final appCheckToken = _appCheckToken(
      app,
      limitedUse: limitedUseAppCheckToken,
    );
    return CallableContext(
      authToken: await authToken,
      appCheckToken: await appCheckToken,
    );
  };
}

Future<String?> _idToken(FirebaseApp app) => idTokenOrNullOnWeb(
      () async => FirebaseAuth.instanceFor(app: app).currentUser?.getIdToken(),
    );

Future<String?> _appCheckToken(
  FirebaseApp app, {
  required bool limitedUse,
}) async {
  final appCheck = app.getService<FirebaseAppCheck>();
  if (appCheck == null) return null;
  return appCheckTokenOrFallback(
    () => limitedUse ? appCheck.getLimitedUseToken() : appCheck.getToken(),
  );
}

/// Returns the ID token from [getToken].
///
/// If fetching it fails, the call fails on Android and Apple, as in the native
/// SDKs. On web ([onWeb]), the error is logged and the call goes out without
/// the token, as in the JS SDK.
@visibleForTesting
Future<String?> idTokenOrNullOnWeb(
  Future<String?> Function() getToken, {
  bool onWeb = kIsWeb,
}) async {
  try {
    return await getToken();
  } catch (error) {
    if (!onWeb) rethrow;
    developer.log(
      'Error getting the Auth ID token, sending the call without it: $error',
      name: 'dart_cloud_functions',
    );
    return null;
  }
}

/// The token the App Check SDKs give other Firebase SDKs when they can't get a
/// real one: base64 for `{"error":"UNKNOWN_ERROR"}`.
///
/// The same value as `DefaultAppCheckTokenResult.DUMMY_TOKEN` on Android and
/// `kPlaceholderTokenValue` in the Apple SDK's AppCheckCore.
@visibleForTesting
const placeholderAppCheckToken = 'eyJlcnJvciI6IlVOS05PV05fRVJST1IifQ==';

/// Returns the App Check token from [getToken], or a fallback if fetching it
/// fails.
///
/// An App Check failure never fails the call. On Android and Apple, the
/// request carries [placeholderAppCheckToken], as in the native SDKs. On web
/// ([onWeb]), it goes out without the header, as in the JS SDK. Either way, a
/// function that enforces App Check rejects it.
@visibleForTesting
Future<String?> appCheckTokenOrFallback(
  Future<String?> Function() getToken, {
  bool onWeb = kIsWeb,
}) async {
  try {
    return await getToken();
  } catch (error) {
    final sending = onWeb ? 'without one' : 'with a placeholder';
    developer.log(
      'Error getting App Check token, sending the call $sending: $error',
      name: 'dart_cloud_functions',
    );
    return onWeb ? null : placeholderAppCheckToken;
  }
}
