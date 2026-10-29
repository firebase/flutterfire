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
  const CallableContext({this.authToken});

  /// The signed-in user's Firebase ID token, or `null` when nobody is signed
  /// in.
  final String? authToken;

  /// Whether the request would carry any credentials.
  bool get hasTokens => authToken != null;
}

/// Returns the tokens for the next callable request.
///
/// Called once per request, so a sign-in or sign-out between two calls takes
/// effect on the next one.
typedef CallableContextProvider = Future<CallableContext> Function();
