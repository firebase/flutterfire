// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of 'cloud_firestore.dart';

/// Result of executing a pipeline
class PipelineResult {
  final DocumentReference<Map<String, dynamic>> document;
  final DateTime createTime;
  final DateTime updateTime;

  PipelineResult({
    required this.document,
    required this.createTime,
    required this.updateTime,
  });
}

/// Snapshot containing pipeline execution results
class PipelineSnapshot {
  final List<PipelineResult> result;
  final DateTime executionTime;

  PipelineSnapshot._(this.result, this.executionTime);
}
