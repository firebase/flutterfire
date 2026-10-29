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
  return appCheckTokenOrNull(
    () => limitedUse ? appCheck.getLimitedUseToken() : appCheck.getToken(),
  );
}

/// Returns the App Check token from [getToken], or `null` if fetching it
/// fails.
///
/// An App Check failure never fails the call, as in the native SDKs and
/// `firebase_data_connect`: the request goes out without the token, and a
/// function that enforces App Check rejects it.
@visibleForTesting
Future<String?> appCheckTokenOrNull(Future<String?> Function() getToken) async {
  try {
    return await getToken();
  } catch (error) {
    developer.log(
      'Sending the call without an App Check token: $error',
      name: 'dart_cloud_functions',
    );
    return null;
  }
}
