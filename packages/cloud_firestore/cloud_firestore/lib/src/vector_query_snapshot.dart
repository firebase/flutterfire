// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// [VectorQuerySnapshot] represents a response to an [VectorQuery] request.
class VectorQuerySnapshot extends _JsonQuerySnapshot {
  VectorQuerySnapshot._(
    super.firestore,
    super.delegate,
  ) : super();
}
