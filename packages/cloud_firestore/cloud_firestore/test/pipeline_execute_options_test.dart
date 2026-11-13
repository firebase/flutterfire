// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import './mock.dart';

void main() {
  group('IndexMode', () {
    test('recommended has expected name', () {
      expect(IndexMode.recommended.name, 'recommended');
    });
  });

  group('ExecuteOptions', () {
    test('default indexMode is recommended', () {
      const options = ExecuteOptions();
      expect(options.indexMode, IndexMode.recommended);
    });

    test('atomic defaults to false', () {
      const options = ExecuteOptions();
      expect(options.atomic, isFalse);
    });

    test('atomic can be enabled', () {
      const options = ExecuteOptions(atomic: true);
      expect(options.atomic, isTrue);
    });
  });

  group('Pipeline.execute options', () {
    final recorder = _ExecuteRecorder();

    setUpAll(() async {
      setupCloudFirestoreMocks();
      await Firebase.initializeApp();
      FirebaseFirestorePlatform.instance = _RecordingFirestore(recorder);
    });

    setUp(recorder.reset);

    test('includes atomic only when it is enabled', () async {
      await expectLater(
        FirebaseFirestore.instance
            .pipeline()
            .collection('users')
            .execute(options: const ExecuteOptions(atomic: true)),
        throwsA(isA<UnsupportedError>()),
      );

      expect(recorder.called, isTrue);
      expect(recorder.options, {'indexMode': 'recommended', 'atomic': true});
    });

    test('omits atomic when ExecuteOptions uses the default', () async {
      await expectLater(
        FirebaseFirestore.instance
            .pipeline()
            .collection('users')
            .execute(options: const ExecuteOptions()),
        throwsA(isA<UnsupportedError>()),
      );

      expect(recorder.called, isTrue);
      expect(recorder.options, {'indexMode': 'recommended'});
    });

    test('passes null when execute is called without options', () async {
      await expectLater(
        FirebaseFirestore.instance.pipeline().collection('users').execute(),
        throwsA(isA<UnsupportedError>()),
      );

      expect(recorder.called, isTrue);
      expect(recorder.options, isNull);
    });
  });
}

class _ExecuteRecorder {
  Map<String, dynamic>? options;
  bool called = false;

  void reset() {
    options = null;
    called = false;
  }
}

class _RecordingFirestore extends FirebaseFirestorePlatform {
  _RecordingFirestore(this.recorder)
    : super(appInstance: Firebase.app(), databaseChoice: '(default)');

  final _ExecuteRecorder recorder;

  @override
  FirebaseFirestorePlatform delegateFor({
    required FirebaseApp app,
    required String databaseId,
  }) {
    return this;
  }

  @override
  PipelinePlatform pipeline(List<Map<String, dynamic>> initialStages) {
    return _RecordingPipeline(this, initialStages, recorder);
  }
}

class _RecordingPipeline extends PipelinePlatform {
  _RecordingPipeline(
    FirebaseFirestorePlatform firestore,
    List<Map<String, dynamic>>? stages,
    this.recorder,
  ) : super(firestore, stages);

  final _ExecuteRecorder recorder;

  @override
  PipelinePlatform addStage(Map<String, dynamic> serializedStage) {
    return _RecordingPipeline(firestore, <Map<String, dynamic>>[
      ...stages,
      serializedStage,
    ], recorder);
  }

  @override
  Future<PipelineSnapshotPlatform> execute({Map<String, dynamic>? options}) {
    recorder
      ..called = true
      ..options = options;
    return Future<PipelineSnapshotPlatform>.error(
      UnsupportedError('execute options recorded'),
    );
  }
}
