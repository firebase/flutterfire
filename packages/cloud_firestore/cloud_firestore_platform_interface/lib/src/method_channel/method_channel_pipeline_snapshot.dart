// ignore_for_file: require_trailing_commas
// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_platform_interface/src/method_channel/method_channel_document_reference.dart';

/// An implementation of [PipelineSnapshotPlatform] that uses [MethodChannel] to
/// communicate with Firebase plugins.
class MethodChannelPipelineSnapshot extends PipelineSnapshotPlatform {
  final List<PipelineResultPlatform> _results;
  final DateTime _executionTime;

  /// Creates a [MethodChannelPipelineSnapshot] from the given [pigeonSnapshot]
  MethodChannelPipelineSnapshot(
    FirebaseFirestorePlatform firestore,
    FirestorePigeonFirebaseApp pigeonApp,
    PigeonPipelineSnapshot pigeonSnapshot,
  )   : _results = pigeonSnapshot.results
            .whereType<PigeonPipelineResult>()
            .map((result) => MethodChannelPipelineResult(
                  firestore,
                  pigeonApp,
                  result.documentPath,
                  result.createTime != null
                      ? DateTime.fromMillisecondsSinceEpoch(result.createTime!)
                      : null,
                  result.updateTime != null
                      ? DateTime.fromMillisecondsSinceEpoch(result.updateTime!)
                      : null,
                  result.data?.cast<String, dynamic>(),
                ))
            .toList(),
        _executionTime = DateTime.fromMillisecondsSinceEpoch(
          pigeonSnapshot.executionTime,
        ),
        super();

  @override
  List<PipelineResultPlatform> get results => _results;

  @override
  DateTime get executionTime => _executionTime;
}

/// An implementation of [PipelineResultPlatform] that uses [MethodChannel] to
/// communicate with Firebase plugins.
class MethodChannelPipelineResult extends PipelineResultPlatform {
  final DocumentReferencePlatform _document;
  final DateTime? _createTime;
  final DateTime? _updateTime;
  final Map<String, dynamic>? _data;

  MethodChannelPipelineResult(
    FirebaseFirestorePlatform firestore,
    FirestorePigeonFirebaseApp pigeonApp,
    String? documentPath,
    this._createTime,
    this._updateTime,
    Map<String, dynamic>? data,
  )   : _document = MethodChannelDocumentReference(
          firestore,
          documentPath ?? '',
          pigeonApp,
        ),
        _data = data,
        super();

  @override
  DocumentReferencePlatform get document => _document;

  @override
  DateTime? get createTime => _createTime;

  @override
  DateTime? get updateTime => _updateTime;

  @override
  Map<String, dynamic>? get data => _data;
}
