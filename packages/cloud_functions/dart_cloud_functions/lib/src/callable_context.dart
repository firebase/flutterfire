// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// The tokens attached to one callable request.
///
/// Plays the role of `HttpsCallableContext` in the Android SDK and
/// `FunctionsContext` in the Apple SDKs.
@immutable
class CallableContext {
  /// Creates a context with the given tokens.
  const CallableContext({this.authToken, this.appCheckToken});

  /// The signed-in user's Firebase ID token, or `null` when nobody is signed
  /// in.
  ///
  /// On web, it's also `null` when fetching the token fails, as in the JS SDK.
  final String? authToken;

  /// The App Check token, or `null` when the app doesn't use App Check.
  ///
  /// When fetching a token fails, this is the placeholder token the native
  /// SDKs send in that case. On web, it's `null` instead, as in the JS SDK.
  final String? appCheckToken;

  /// Whether the request would carry any credentials.
  bool get hasTokens => authToken != null || appCheckToken != null;
}

/// Returns the tokens for the next callable request.
///
/// Called once per request, so a sign-in or sign-out between two calls takes
/// effect on the next one. [limitedUseAppCheckToken] asks for a limited-use
/// App Check token instead of the standard one.
typedef CallableContextProvider = Future<CallableContext> Function({
  required bool limitedUseAppCheckToken,
});
