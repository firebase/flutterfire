// ignore_for_file: require_trailing_commas
// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_interop';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_web/src/interop/utils/utils.dart';

import 'document_reference_web.dart';
import 'interop/firestore.dart' as firestore_interop;
import 'interop/firestore_interop.dart' as interop;

/// Web implementation of [PipelinePlatform].
class PipelineWeb extends PipelinePlatform {
  final firestore_interop.Firestore _firestoreWeb;

  PipelineWeb(
    FirebaseFirestorePlatform firestore,
    this._firestoreWeb,
    List<Map<String, dynamic>>? stages,
  ) : super(firestore, stages);

  @override
  PipelinePlatform addStage(Map<String, dynamic> serializedStage) {
    return PipelineWeb(
      firestore,
      _firestoreWeb,
      [...stages, serializedStage],
    );
  }

  @override
  Future<PipelineSnapshotPlatform> execute({
    Map<String, dynamic>? options,
  }) async {
    return firestore.executePipeline(stages, options: options);
  }
}

/// Web implementation of [PipelineSnapshotPlatform].
class PipelineSnapshotWeb extends PipelineSnapshotPlatform {
  PipelineSnapshotWeb(this._results, this._executionTime) : super();

  final List<PipelineResultPlatform> _results;
  final DateTime _executionTime;

  @override
  List<PipelineResultPlatform> get results => _results;

  @override
  DateTime get executionTime => _executionTime;
}

/// Web implementation of [PipelineResultPlatform].
class PipelineResultWeb extends PipelineResultPlatform {
  PipelineResultWeb(
    FirebaseFirestorePlatform firestore,
    firestore_interop.Firestore firestoreWeb,
    interop.PipelineResultJsImpl jsResult,
  )   : _document = jsResult.ref != null
            ? DocumentReferenceWeb(
                firestore,
                firestoreWeb,
                jsResult.ref!.path.toDart,
              )
            : null,
        _createTime = _timestampToDateTime(jsResult.createTime),
        _updateTime = _timestampToDateTime(jsResult.updateTime),
        _data = _dataFromResult(jsResult),
        super();

  final DocumentReferencePlatform? _document;
  final DateTime? _createTime;
  final DateTime? _updateTime;
  final Map<String, dynamic>? _data;

  static Map<String, dynamic>? _dataFromResult(
      interop.PipelineResultJsImpl jsResult) {
    final d = jsResult.data();
    return d != null
        ? Map<String, dynamic>.from(dartify(d) as Map<Object?, Object?>)
        : null;
  }

  static DateTime? _timestampToDateTime(JSAny? value) {
    if (value == null) return null;
    final d = dartify(value);
    if (d == null) return null;
    if (d is DateTime) return d;
    if (d is Timestamp) return d.toDate();
    if (d is int) return DateTime.fromMillisecondsSinceEpoch(d);
    return null;
  }

  @override
  DocumentReferencePlatform? get document => _document;

  @override
  DateTime? get createTime => _createTime;

  @override
  DateTime? get updateTime => _updateTime;

  @override
  Map<String, dynamic>? get data => _data;
}
