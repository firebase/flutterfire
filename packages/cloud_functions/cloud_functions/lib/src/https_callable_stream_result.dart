// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_functions/cloud_functions.dart';

/// Represents a response from a Server-Sent Event (SSE) stream.
sealed class StreamResponse<T> {}

/// A chunk received during the stream.
class Chunk<T> extends StreamResponse<T> {
  final T partialData;
  Chunk(this.partialData);
}

/// The final result of the computation, marking the end of the stream.
class Result<T> extends StreamResponse<T> {
  final HttpsCallableResult<T> result;
  Result(this.result);
}
