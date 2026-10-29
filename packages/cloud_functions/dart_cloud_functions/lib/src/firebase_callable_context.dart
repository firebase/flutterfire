// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:developer' as developer;

import 'package:dart_cloud_functions/src/callable_context.dart';
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

Future<String?> _idToken(FirebaseApp app) async =>
    FirebaseAuth.instanceFor(app: app).currentUser?.getIdToken();

Future<String?> _appCheckToken(
  FirebaseApp app, {
  required bool limitedUse,
}) async {
  final appCheck = app.getService<FirebaseAppCheck>();
  if (appCheck == null) return null;
  return appCheckTokenOrPlaceholder(
    () => limitedUse ? appCheck.getLimitedUseToken() : appCheck.getToken(),
  );
}

/// The token the App Check SDKs give other Firebase SDKs when they can't get a
/// real one: base64 for `{"error":"UNKNOWN_ERROR"}`.
///
/// The same value as `DefaultAppCheckTokenResult.DUMMY_TOKEN` on Android and
/// `kPlaceholderTokenValue` in the Apple SDK's AppCheckCore.
@visibleForTesting
const placeholderAppCheckToken = 'eyJlcnJvciI6IlVOS05PV05fRVJST1IifQ==';

/// Returns the App Check token from [getToken], or [placeholderAppCheckToken]
/// if fetching it fails.
///
/// As in the native SDKs, an App Check failure never fails the call: the
/// request carries the placeholder, which a function that enforces App Check
/// rejects as invalid.
@visibleForTesting
Future<String?> appCheckTokenOrPlaceholder(
  Future<String?> Function() getToken,
) async {
  try {
    return await getToken();
  } catch (error) {
    developer.log(
      'Error getting App Check token, sending a placeholder instead: $error',
      name: 'dart_cloud_functions',
    );
    return placeholderAppCheckToken;
  }
}
