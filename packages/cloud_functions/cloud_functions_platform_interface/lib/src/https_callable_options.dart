// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Interface representing an HttpsCallable instance's options,
class HttpsCallableOptions {
  /// Constructs a new [HttpsCallableOptions] instance with given `timeout` & `limitedUseAppCheckToken`
  /// Defaults [timeout] to 60 seconds.
  /// Defaults [limitedUseAppCheckToken] to `false`
  HttpsCallableOptions(
      {this.timeout = const Duration(seconds: 60),
      this.limitedUseAppCheckToken = false,
      this.webAbortSignal});

  /// Returns the timeout for this instance
  Duration timeout;

  /// Sets whether or not to use limited-use App Check tokens when invoking the associated function.
  bool limitedUseAppCheckToken;

  /// An AbortSignal that can be used to cancel the streaming response.
  /// When the signal is aborted, the underlying HTTP connection will be terminated.
  AbortSignal? webAbortSignal;
}

/// Represents a base class for encapsulating abort signals.
sealed class AbortSignal {}

/// Creates an [AbortSignal] that will automatically abort after a specified [time].
///
/// This is equivalent to calling `AbortSignal.timeout(ms)` in the Web SDK.
///
/// Typically used to cancel long-running operations after a timeout duration.
///
/// Example:
/// ```dart
/// final signal = HttpsCallableOptions(webAbortSignal: TimeLimit(Duration(seconds: 10)));
/// ```
class TimeLimit extends AbortSignal {
  final Duration time;
  TimeLimit(this.time);
}

/// Creates an [AbortSignal] that is immediately aborted with an optional [reason].
///
/// This is equivalent to calling `AbortSignal.abort(reason)` in the Web SDK.
///
/// Useful when you want to explicitly cancel a callable before it begins, or to provide
/// a specific reason for cancellation.
///
/// Example:
/// ```dart
/// final signal = HttpsCallableOptions(webAbortSignal: Abort('User exited'));
/// ```
class Abort extends AbortSignal {
  final Object? reason;
  Abort([this.reason]);
}

/// Creates an [AbortSignal] that is aborted when **any** of the provided [signals] is aborted.
///
/// This is equivalent to calling `AbortSignal.any([...])` in the Web SDK.
///
/// Useful for combining multiple abort conditions.
///
/// Example:
/// ```dart
/// final signal = HttpsCallableOptions(
///   webAbortSignal: Any([
///     TimeLimit(Duration(seconds: 10)),
///     Abort('User cancelled'),
///   ]),
/// );
/// ```
class Any extends AbortSignal {
  final List<AbortSignal> signals;
  Any(this.signals);
}
