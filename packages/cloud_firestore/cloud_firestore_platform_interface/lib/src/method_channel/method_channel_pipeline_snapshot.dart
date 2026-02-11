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

  /// Creates a [MethodChannelPipelineSnapshot] from the given [data]
  MethodChannelPipelineSnapshot(
    FirebaseFirestorePlatform firestore,
    FirestorePigeonFirebaseApp pigeonApp,
    Map<String, dynamic> data,
  )   : _results = (data['results'] as List)
            .map((result) => MethodChannelPipelineResult(
                  firestore,
                  pigeonApp,
                  result['document'] as String,
                  DateTime.fromMillisecondsSinceEpoch(result['createTime']),
                  DateTime.fromMillisecondsSinceEpoch(result['updateTime']),
                ))
            .toList(),
        _executionTime = DateTime.fromMillisecondsSinceEpoch(
          data['executionTime'] as int,
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
  final DateTime _createTime;
  final DateTime _updateTime;

  MethodChannelPipelineResult(
    FirebaseFirestorePlatform firestore,
    FirestorePigeonFirebaseApp pigeonApp,
    String documentPath,
    this._createTime,
    this._updateTime,
  )   : _document = MethodChannelDocumentReference(
          firestore,
          documentPath,
          pigeonApp,
        ),
        super();

  @override
  DocumentReferencePlatform get document => _document;

  @override
  DateTime get createTime => _createTime;

  @override
  DateTime get updateTime => _updateTime;
}
