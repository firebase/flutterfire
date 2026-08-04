// ignore_for_file: require_trailing_commas
// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:meta/meta.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Represents a pipeline for querying and transforming Firestore data.
@immutable
abstract class PipelinePlatform extends PlatformInterface {
  /// Create a [PipelinePlatform] instance
  PipelinePlatform(this.firestore, List<Map<String, dynamic>>? stages)
      : _stages = stages ?? [],
        super(token: _token);

  static final Object _token = Object();

  /// Throws an [AssertionError] if [instance] does not extend
  /// [PipelinePlatform].
  ///
  /// This is used by the app-facing [Pipeline] to ensure that
  /// the object in which it's going to delegate calls has been
  /// constructed properly.
  static void verify(PipelinePlatform instance) {
    PlatformInterface.verify(instance, _token);
  }

  /// The [FirebaseFirestorePlatform] interface for this current pipeline.
  final FirebaseFirestorePlatform firestore;

  /// Stores the pipeline stages.
  final List<Map<String, dynamic>> _stages;

  /// Exposes the [stages] on the pipeline delegate.
  ///
  /// This should only be used for testing to ensure that all
  /// pipeline stages are correctly set on the underlying delegate
  /// when being tested from a different package.
  List<Map<String, dynamic>> get stages {
    return List.unmodifiable(_stages);
  }

  /// Adds a serialized stage to the pipeline
  PipelinePlatform addStage(Map<String, dynamic> serializedStage);

  /// Executes the pipeline and returns a snapshot of the results
  Future<PipelineSnapshotPlatform> execute({
    Map<String, dynamic>? options,
  });
}
