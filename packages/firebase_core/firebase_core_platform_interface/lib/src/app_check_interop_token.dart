// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../firebase_core_platform_interface.dart';

/// The App Check SDK's answer to a token request, as the native SDKs report
/// it.
///
/// When the SDK can't produce a token (for example before App Check is
/// activated), [token] holds the SDK's placeholder and [error] the reason.
/// Consumers decide whether to attach the placeholder; the Functions SDKs do.
@immutable
class AppCheckInteropToken {
  /// Creates the SDK's answer: a [token] and, on failure, the [error].
  const AppCheckInteropToken({required this.token, this.error});

  /// The App Check token, or the SDK's placeholder when [error] is set.
  final String token;

  /// Why the SDK couldn't produce a token, or `null` when [token] is real.
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
