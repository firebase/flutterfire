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
  final IndexMode indexMode;

  const ExecuteOptions({
    this.indexMode = IndexMode.recommended,
  });
}
