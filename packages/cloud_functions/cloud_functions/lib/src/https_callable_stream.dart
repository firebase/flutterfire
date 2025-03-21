// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../cloud_functions.dart';

class HttpsCallableStream<R> {
  HttpsCallableStream._(this.delegate);

  /// Returns the underlying [HttpsCallableStream] delegate for this
  /// [HttpsCallableStreamsPlatform] instance. This is useful for testing purposes only.
  @visibleForTesting
  final HttpsCallableStreamsPlatform delegate;

  Stream<Chunk<T>> stream<T>(Object? input) async* {
    await for (final T value in delegate.stream<T>(input)) {
      yield Chunk<T>(value);
    }
  }

// Future<R> get data => delegate.data;
}
