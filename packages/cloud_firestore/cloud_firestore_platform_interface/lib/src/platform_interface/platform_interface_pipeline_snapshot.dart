// ignore_for_file: require_trailing_commas
// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../../cloud_firestore_platform_interface.dart';
import 'platform_interface_document_reference.dart';

/// Platform interface for [PipelineSnapshot].
abstract class PipelineSnapshotPlatform extends PlatformInterface {
  /// Create an instance of [PipelineSnapshotPlatform].
  PipelineSnapshotPlatform() : super(token: _token);

  static final Object _token = Object();

  /// The results of the pipeline execution
  List<PipelineResultPlatform> get results;

  /// The execution time of the pipeline
  DateTime get executionTime;
}

/// Platform interface for [PipelineResult].
abstract class PipelineResultPlatform extends PlatformInterface {
  /// Create an instance of [PipelineResultPlatform].
  PipelineResultPlatform() : super(token: _token);

  static final Object _token = Object();

  /// The document reference
  DocumentReferencePlatform get document;

  /// The creation time of the document
  DateTime? get createTime;

  /// The update time of the document
  DateTime? get updateTime;

  /// All fields in the result (from PipelineResult.data() on the native SDK).
  /// Returns null if the result has no data.
  Map<String, dynamic>? get data;
}
