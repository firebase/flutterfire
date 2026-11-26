// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

/// An App Check implementation's answer to a token request, in the shape the
/// Firebase SDKs hand each other.
///
/// When App Check can't produce a token (for example before it is activated,
/// or when attestation fails), [token] holds [placeholderToken] and [error]
/// the reason. Consumers decide whether to attach the placeholder: the native
/// Functions SDKs send it, the JS Functions SDK omits the header.
@immutable
class AppCheckInteropToken {
  /// Creates the answer: a [token] and, on failure, the [error].
  const AppCheckInteropToken({required this.token, this.error});

  /// The answer when no token could be produced for the reason in [error].
  const AppCheckInteropToken.failure(String error)
    : this(token: placeholderToken, error: error);

  /// The token the App Check SDKs give other Firebase SDKs when they can't
  /// produce a real one: base64 for `{"error":"UNKNOWN_ERROR"}`.
  ///
  /// The same value as `DefaultAppCheckTokenResult.DUMMY_TOKEN` on Android,
  /// `kPlaceholderTokenValue` in the Apple SDK's AppCheckCore and the
  /// JS SDK's `formatDummyToken` output.
  static const String placeholderToken = 'eyJlcnJvciI6IlVOS05PV05fRVJST1IifQ==';

  /// The App Check token, or [placeholderToken] when [error] is set.
  final String token;

  /// Why no token could be produced, or `null` when [token] is real.
  final String? error;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppCheckInteropToken &&
          other.token == token &&
          other.error == error;

  @override
  int get hashCode => Object.hash(token, error);

  /// Describes the answer without printing the token itself.
  @override
  String toString() =>
      '$AppCheckInteropToken(token: <${token.length} chars>, error: $error)';
}
