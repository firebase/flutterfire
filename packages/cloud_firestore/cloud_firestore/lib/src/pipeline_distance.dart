// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../cloud_firestore.dart';

/// Distance measure algorithms for vector similarity search
enum DistanceMeasure {
  /// Cosine similarity
  cosine,

  /// Euclidean distance
  euclidean,

  /// Dot product
  dotProduct,
}
