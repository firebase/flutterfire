// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../cloud_functions.dart';

class HttpsCallableStream {
  HttpsCallableStream._(this.delegate);

  /// Returns the underlying [HttpsCallableStream] delegate for this
  /// [HttpsCallableStreamsPlatform] instance. This is useful for testing purposes only.
  @visibleForTesting
  final HttpsCallableStreamsPlatform delegate;

  Stream<StreamResponse> stream<T, R>([Object? input]) async* {
    await for (final value in delegate.stream(input)) {
      if (value is Map) {
        if (value.containsKey('message')) {
          yield Chunk<T>(value['message'] as T);
        } else if (value.containsKey('result')) {
          yield Result<R>(HttpsCallableResult._(value['result'] as R));
        }
      }
    }
  }
}
