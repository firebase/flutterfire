// ignore_for_file: require_trailing_commas
// Copyright 2025, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../cloud_functions.dart';

/// Represents a response from a Server-Sent Event (SSE) stream.
sealed class StreamResponse<T, R> {}

/// A chunk received during the stream.
class Chunk<T, R> extends StreamResponse<T, R> {
  /// The intermediate data received from the server.
  final T partialData;
  Chunk(this.partialData);
}

/// The final result of the computation, marking the end of the stream.
class Result<T, R> extends StreamResponse<T, R> {
  /// The final computed result received from the server.
  final HttpsCallableResult<R> result;
  Result(this.result);
}
