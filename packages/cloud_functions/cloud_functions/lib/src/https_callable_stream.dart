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

  /// Streams data to the specified HTTPS endpoint.
  ///
  /// The data passed into the trigger can be any of the following types:
  ///
  /// `null`
  /// `String`
  /// `num`
  /// [List], where the contained objects are also one of these types.
  /// [Map], where the values are also one of these types.
  ///
  /// The request to the Cloud Functions backend made by this method
  /// automatically includes a Firebase Instance ID token to identify the app
  /// instance. If a user is logged in with Firebase Auth, an auth ID token for
  /// the user is also automatically included.
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
