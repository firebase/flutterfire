// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../cloud_firestore.dart';

/// Represents the results of a Pipeline query, including the data and metadata.
class PipelineResult {
  /// The document reference, or null if no document was returned.
  final DocumentReference<Map<String, dynamic>>? document;
  /// The time the document was created.
  final DateTime? createTime;
  /// The time the document was last updated (at the time the snapshot was generated).
  final DateTime? updateTime;
  /// Retrieves all fields in the result as a map.
  final Map<String, dynamic>? _data;

  PipelineResult({
    this.document,
    this.createTime,
    this.updateTime,
    Map<String, dynamic>? data,
  }) : _data = data;

  /// Retrieves all fields in the result as a map.
  Map<String, dynamic>? data() => _data;
}

/// A [PipelineSnapshot] contains the results of a pipeline execution. It can be iterated to retrieve the individual [PipelineResult] objects.
class PipelineSnapshot {
  /// List of all the results
  final List<PipelineResult> result;
  /// The time at which the pipeline producing this result is executed.
  final DateTime executionTime;

  PipelineSnapshot._(this.result, this.executionTime);
}
