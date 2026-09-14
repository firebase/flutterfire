// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/services.dart';

/// A stand-in for `flutter_test`'s `TestDefaultBinaryMessengerBinding`, used by
/// the generated Pigeon test APIs that ship in `lib/`.
///
/// Pigeon generates its test API against `flutter_test`, but a package cannot
/// import a dev dependency from `lib/`, and depending on `flutter_test` for
/// real pins `test_api` for every consumer of this package, which breaks
/// version solving for apps that use `package:test`
/// (https://github.com/firebase/flutterfire/issues/17001).
///
/// The generated files only ever need to install and remove mock handlers, so
/// this reaches the test binary messenger through [ServicesBinding] instead.
/// Callers already run inside `flutter_test` (that is where the test binding
/// comes from), so the messenger is a `TestDefaultBinaryMessenger` at runtime
/// and the dynamic call below resolves to `setMockMessageHandler`.
class TestDefaultBinaryMessengerBinding {
  const TestDefaultBinaryMessengerBinding._();

  /// The current binding, mirroring
  /// `TestDefaultBinaryMessengerBinding.instance`.
  static TestDefaultBinaryMessengerBinding? get instance =>
      const TestDefaultBinaryMessengerBinding._();

  /// The mock-handler surface of the test binding's default binary messenger.
  TestBinaryMessenger get defaultBinaryMessenger =>
      TestBinaryMessenger._(ServicesBinding.instance.defaultBinaryMessenger);
}

/// The subset of `flutter_test`'s `TestDefaultBinaryMessenger` that generated
/// Pigeon test APIs rely on.
class TestBinaryMessenger {
  const TestBinaryMessenger._(this._messenger);

  final BinaryMessenger _messenger;

  /// Intercepts messages sent on [channel], decoding them with the channel's
  /// codec before handing them to [handler].
  ///
  /// Mirrors `TestDefaultBinaryMessenger.setMockDecodedMessageHandler`.
  void setMockDecodedMessageHandler<T>(
    BasicMessageChannel<T> channel,
    Future<T> Function(T? message)? handler,
  ) {
    if (handler == null) {
      _setMockMessageHandler(channel.name, null);
      return;
    }
    _setMockMessageHandler(channel.name, (ByteData? message) async {
      return channel.codec
          .encodeMessage(await handler(channel.codec.decodeMessage(message)));
    });
  }

  void _setMockMessageHandler(
    String channel,
    Future<ByteData?> Function(ByteData?)? handler,
  ) {
    // ignore: avoid_dynamic_calls
    (_messenger as dynamic).setMockMessageHandler(channel, handler);
  }
}
