// ignore_for_file: require_trailing_commas, unnecessary_lambdas
// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_platform_interface/src/platform_interface/platform_interface_pipeline.dart'
    as pipeline;

/// An implementation of [PipelinePlatform] that uses [MethodChannel] to
/// communicate with Firebase plugins.
class MethodChannelPipeline extends pipeline.PipelinePlatform {
  /// Create a [MethodChannelPipeline] from [stages]
  MethodChannelPipeline(
    FirebaseFirestorePlatform _firestore,
    this.pigeonApp, {
    List<Map<String, dynamic>>? stages,
  }) : super(_firestore, stages);

  final FirestorePigeonFirebaseApp pigeonApp;

  /// Creates a new instance of [MethodChannelPipeline], however overrides
  /// any existing [stages].
  ///
  /// This is in place to ensure that changes to a pipeline don't mutate
  /// other pipelines.
  MethodChannelPipeline _copyWithStages(List<Map<String, dynamic>> newStages) {
    return MethodChannelPipeline(
      firestore,
      pigeonApp,
      stages: List.unmodifiable([...stages, ...newStages]),
    );
  }

  @override
  pipeline.PipelinePlatform addStage(Map<String, dynamic> serializedStage) {
    return _copyWithStages([serializedStage]);
  }

  @override
  Future<PipelineSnapshotPlatform> execute({
    Map<String, dynamic>? options,
  }) async {
    _rejectWebOnlyStages(stages);
    return firestore.executePipeline(stages, options: options);
  }
}

void _rejectWebOnlyStages(List<dynamic> stages) {
  for (final stage in stages) {
    if (stage is! Map) {
      continue;
    }
    final name = stage['stage'];
    if (name is String && _webOnlyPipelineStages.contains(name)) {
      throw UnsupportedError(
        'Pipeline $name is currently supported on web only.',
      );
    }
    if (name == 'union') {
      final args = stage['args'];
      if (args is Map) {
        final nestedStages = args['pipeline'];
        if (nestedStages is List) {
          _rejectWebOnlyStages(nestedStages);
        }
      }
    }
  }
}

const _webOnlyPipelineStages = {
  'literals',
  'delete',
  'update',
  'insert',
  'upsert',
};
