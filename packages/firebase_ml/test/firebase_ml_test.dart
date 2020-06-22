// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_ml/firebase_ml.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  String MODEL_NAME = "myModelName";
  String MODEL_FILE_PATH = "someDestination";

  group('$FirebaseRemoteModel()', () {
    test('constructor creates a valid model with correct name', () {
      var model = FirebaseCustomRemoteModel(MODEL_NAME);
      expect(model, isA<FirebaseRemoteModel>());
      expect(model, isNotNull);
      expect(model.modelName, MODEL_NAME);
    });
    test('constructor throws exception when name is null', () {
      expect(() => FirebaseCustomRemoteModel(null),
          throwsA(isA<AssertionError>()));
    });
  });

  group('$FirebaseModelDownloadConditions()', () {
    test('constructor defaults to right values', () {
      FirebaseModelDownloadConditions conditions =
          FirebaseModelDownloadConditions();
      expect(conditions.androidRequireWifi, false);
      expect(conditions.androidRequireDeviceIdle, false);
      expect(conditions.androidRequireCharging, false);
      expect(conditions.iosAllowBackgroundDownloading, false);
      expect(conditions.iosAllowCellularAccess, true);
    });
    test('constructor assigns values correctly', () {
      FirebaseModelDownloadConditions conditions =
          FirebaseModelDownloadConditions(
              androidRequireWifi: true,
              androidRequireDeviceIdle: true,
              androidRequireCharging: true,
              iosAllowBackgroundDownloading: true,
              iosAllowCellularAccess: false);
      expect(conditions.androidRequireWifi, true);
      expect(conditions.androidRequireDeviceIdle, true);
      expect(conditions.androidRequireCharging, true);
      expect(conditions.iosAllowBackgroundDownloading, true);
      expect(conditions.iosAllowCellularAccess, false);
    });
    test('constructor throws exception if androidRequireWifi is null', () {
      expect(() => FirebaseModelDownloadConditions(androidRequireWifi: null),
          throwsA(isA<AssertionError>()));
    });
    test('constructor throws exception if androidRequireDeviceIdle is null',
        () {
      expect(
          () => FirebaseModelDownloadConditions(androidRequireDeviceIdle: null),
          throwsA(isA<AssertionError>()));
    });
    test('constructor throws exception if androidRequireCharging is null', () {
      expect(
          () => FirebaseModelDownloadConditions(androidRequireCharging: null),
          throwsA(isA<AssertionError>()));
    });
    test(
        'constructor throws exception if iosAllowBackgroundDownloading is null',
        () {
      expect(
          () => FirebaseModelDownloadConditions(
              iosAllowBackgroundDownloading: null),
          throwsA(isA<AssertionError>()));
    });
    test('constructor throws exception if iosAllowCellularAccess is null', () {
      expect(
          () => FirebaseModelDownloadConditions(iosAllowCellularAccess: null),
          throwsA(isA<AssertionError>()));
    });
    test('conditions are passed as a map correctly', () {
      Map<String, bool> conditionsMap =
          FirebaseModelDownloadConditions().toMap();
      expect(conditionsMap['androidRequireWifi'], false);
      expect(conditionsMap['androidRequireDeviceIdle'], false);
      expect(conditionsMap['androidRequireCharging'], false);
      expect(conditionsMap['iosAllowBackgroundDownloading'], false);
      expect(conditionsMap['iosAllowCellularAccess'], true);
    });
  });

  group('$FirebaseModelManager', () {
    test('constructor creates a valid model manager', () {
      final FirebaseModelManager modelManager = FirebaseModelManager.instance;
      expect(modelManager, isNotNull);
    });

    group('$FirebaseModelManager fails when gets incorrect inputs', () {
      final FirebaseModelManager modelManager = FirebaseModelManager.instance;

      test('manager tries to download model when model is null', () {
        var conditions = FirebaseModelDownloadConditions();
        expect(modelManager.download(null, conditions),
            throwsA(isA<AssertionError>()));
      });
      test('manager tries to download model when conditions are null', () {
        var model = FirebaseCustomRemoteModel(MODEL_NAME);
        expect(
            modelManager.download(model, null), throwsA(isA<AssertionError>()));
      });
      test('manager tries to check if model is downloaded when model is null',
          () {
        expect(modelManager.isModelDownloaded(null),
            throwsA(isA<AssertionError>()));
      });
      test('manager tries to get latest model file when model is null', () {
        expect(modelManager.getLatestModelFile(null),
            throwsA(isA<AssertionError>()));
      });
    });

    group('$FirebaseModelManager successfully communicates with native API',
        () {
      final List<MethodCall> log = <MethodCall>[];
      final FirebaseModelManager modelManager = FirebaseModelManager.instance;
      FirebaseCustomRemoteModel model = FirebaseCustomRemoteModel(MODEL_NAME);
      setUp(() {
        FirebaseModelManager.channel
            .setMockMethodCallHandler((MethodCall methodCall) async {
          log.add(methodCall);

          switch (methodCall.method) {
            case 'FirebaseModelManager#download':
              return null;
            case 'FirebaseModelManager#getLatestModelFile':
              return MODEL_FILE_PATH;
            case 'FirebaseModelManager#isModelDownloaded':
              return true;
            default:
              throw Exception("Not implemented");
          }
        });
        log.clear();
      });

      tearDown(() {
        FirebaseModelManager.channel.setMockMethodCallHandler(null);
      });

      test('manager downloads model', () async {
        var conditions =
            FirebaseModelDownloadConditions(androidRequireWifi: true);

        await modelManager.download(model, conditions);

        expect(
          log,
          <Matcher>[
            isMethodCall(
              'FirebaseModelManager#download',
              arguments: <String, dynamic>{
                'modelName': MODEL_NAME,
                'conditions': conditions.toMap(),
              },
            ),
          ],
        );
      });
      test('manager checks if model is downloaded', () async {
        var isModelDownloaded = await modelManager.isModelDownloaded(model);
        expect(isModelDownloaded, isTrue);

        expect(
          log,
          <Matcher>[
            isMethodCall(
              'FirebaseModelManager#isModelDownloaded',
              arguments: <String, dynamic>{
                'modelName': MODEL_NAME,
              },
            ),
          ],
        );
      });
      test('manager gets model file', () async {
        var modelFile = await modelManager.getLatestModelFile(model);
        expect(modelFile.path, MODEL_FILE_PATH);

        expect(
          log,
          <Matcher>[
            isMethodCall(
              'FirebaseModelManager#getLatestModelFile',
              arguments: <String, dynamic>{
                'modelName': MODEL_NAME,
              },
            ),
          ],
        );
      });
    });

    group('$FirebaseModelManager fails to communicate with native API', () {
      final FirebaseModelManager modelManager = FirebaseModelManager.instance;
      FirebaseCustomRemoteModel model = FirebaseCustomRemoteModel(MODEL_NAME);

      setUp(() {
        FirebaseModelManager.channel
            .setMockMethodCallHandler((MethodCall methodCall) async {
          throw Exception("There is some problem with a call");
        });
      });

      tearDown(() {
        FirebaseModelManager.channel.setMockMethodCallHandler(null);
      });

      test('manager fails to download model', () async {
        var conditions =
            FirebaseModelDownloadConditions(androidRequireWifi: true);
        expect(modelManager.download(model, conditions), throwsException);
      });
      test('manager fails to check if model is downloaded', () async {
        expect(modelManager.isModelDownloaded(model), throwsException);
      });
      test('manager fails to get model file', () async {
        expect(modelManager.getLatestModelFile(model), throwsException);
      });
    });
  });
}
