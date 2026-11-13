// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../cloud_firestore.dart';

/// Index mode for pipeline execution
enum IndexMode {
  /// Use recommended index mode
  recommended,
}

/// Options for executing a pipeline
class ExecuteOptions {
  /// Which indexes the backend may use.
  final IndexMode indexMode;

  /// When true, data-manipulation stages commit in one transaction.
  ///
  /// When false, each document write is applied on its own and a pipeline
  /// can partially succeed. Some writes, such as [PipelineSource.literals]
  /// followed by [Pipeline.upsert], are rejected unless this is true.
  final bool atomic;

  const ExecuteOptions({
    this.indexMode = IndexMode.recommended,
    this.atomic = false,
  });
}
