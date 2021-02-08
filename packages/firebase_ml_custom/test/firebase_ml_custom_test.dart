// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_ml_custom/firebase_ml_custom.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const MODEL_NAME = 'myModelName';
  const MODEL_FILE_PATH = 'someDestination';

  group('$FirebaseRemoteModel()', () {
    test('constructor creates a valid model with correct name', () {
      final model = FirebaseCustomRemoteModel(MODEL_NAME);

      expect(model, isA<FirebaseRemoteModel>());
      expect(model, isNotNull);
      expect(model.modelName, MODEL_NAME);
    });

    test('constructor throws exception when name is null', () {
      expect(
          () => FirebaseCustomRemoteModel(null),
          throwsA(isA<AssertionError>().having((e) => e.toString(), 'message',
              contains("'modelName != null': is not true"))));
    });
  });

  group('$FirebaseModelDownloadConditions()', () {
    test('constructor defaults to right values', () {
      final conditions = FirebaseModelDownloadConditions();

      expect(conditions.androidRequireWifi, false);
      expect(conditions.androidRequireDeviceIdle, false);
      expect(conditions.androidRequireCharging, false);
      expect(conditions.iosAllowBackgroundDownloading, false);
      expect(conditions.iosAllowCellularAccess, true);
    });

    test('constructor assigns values correctly', () {
      final conditions = FirebaseModelDownloadConditions(
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
      expect(
          () => FirebaseModelDownloadConditions(androidRequireWifi: null),
          throwsA(isA<AssertionError>().having((e) => e.toString(), 'message',
              contains("'androidRequireWifi != null': is not true"))));
    });

    test('constructor throws exception if androidRequireDeviceIdle is null',
        () {
      expect(
          () => FirebaseModelDownloadConditions(androidRequireDeviceIdle: null),
          throwsA(isA<AssertionError>().having((e) => e.toString(), 'message',
              contains("'androidRequireDeviceIdle != null': is not true"))));
    });

    test('constructor throws exception if androidRequireCharging is null', () {
      expect(
          () => FirebaseModelDownloadConditions(androidRequireCharging: null),
          throwsA(isA<AssertionError>().having((e) => e.toString(), 'message',
              contains("'androidRequireCharging != null': is not true"))));
    });

    test(
        'constructor throws exception if iosAllowBackgroundDownloading is null',
        () {
      expect(
          () => FirebaseModelDownloadConditions(
              iosAllowBackgroundDownloading: null),
          throwsA(isA<AssertionError>().having(
              (e) => e.toString(),
              'message',
              contains(
                  "'iosAllowBackgroundDownloading != null': is not true"))));
    });

    test('constructor throws exception if iosAllowCellularAccess is null', () {
      expect(
          () => FirebaseModelDownloadConditions(iosAllowCellularAccess: null),
          throwsA(isA<AssertionError>().having((e) => e.toString(), 'message',
              contains("'iosAllowCellularAccess != null': is not true"))));
    });

    test('conditions are passed as a map correctly', () {
      final conditionsMap = FirebaseModelDownloadConditions().toMap();

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

    group('when gets incorrect inputs', () {
      final FirebaseModelManager modelManager = FirebaseModelManager.instance;

      test('throws exception when tries to download model if model is null',
          () {
        final conditions = FirebaseModelDownloadConditions();
        expect(
            modelManager.download(null, conditions),
            throwsA(isA<AssertionError>().having((e) => e.toString(), 'message',
                contains("'model != null': is not true"))));
      });

      test(
          'throws exception when tries to download model if conditions are null',
          () {
        final model = FirebaseCustomRemoteModel(MODEL_NAME);
        expect(
            modelManager.download(model, null),
            throwsA(isA<AssertionError>().having((e) => e.toString(), 'message',
                contains("'conditions != null': is not true"))));
      });

      test(
          'throws exception when tries to check if model is downloaded if model is null',
          () {
        expect(
            modelManager.isModelDownloaded(null),
            throwsA(isA<AssertionError>().having((e) => e.toString(), 'message',
                contains("'model != null': is not true"))));
      });

      test(
          'throws exception when tries to get latest model file if model is null',
          () {
        expect(
            modelManager.getLatestModelFile(null),
            throwsA(isA<AssertionError>().having((e) => e.toString(), 'message',
                contains("'model != null': is not true"))));
      });
    });

    group('when successfully communicates with native API', () {
      final List<MethodCall> log = <MethodCall>[];
      final FirebaseModelManager modelManager = FirebaseModelManager.instance;
      final FirebaseCustomRemoteModel model =
          FirebaseCustomRemoteModel(MODEL_NAME);

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
              throw Exception('Not implemented');
          }
        });
        log.clear();
      });

      tearDown(() {
        FirebaseModelManager.channel.setMockMethodCallHandler(null);
      });

      test('downloads model', () async {
        final conditions =
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

      test('checks if model is downloaded', () async {
        final isModelDownloaded = await modelManager.isModelDownloaded(model);

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

      test('gets model file', () async {
        final modelFile = await modelManager.getLatestModelFile(model);

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

    group('when fails to communicate with native API', () {
      final FirebaseModelManager modelManager = FirebaseModelManager.instance;
      final FirebaseCustomRemoteModel model =
          FirebaseCustomRemoteModel(MODEL_NAME);
      const ERROR_MESSAGE = 'There is some problem with a call';

      setUp(() {
        FirebaseModelManager.channel
            .setMockMethodCallHandler((MethodCall methodCall) async {
          throw Exception(ERROR_MESSAGE);
        });
      });

      tearDown(() {
        FirebaseModelManager.channel.setMockMethodCallHandler(null);
      });

      test('throws exception when fails to download model', () async {
        final conditions =
            FirebaseModelDownloadConditions(androidRequireWifi: true);
        expect(
            modelManager.download(model, conditions),
            throwsA(isA<PlatformException>().having(
                (e) => e.toString(), 'message', contains(ERROR_MESSAGE))));
      });

      test('throws exception when fails to check if model is downloaded',
          () async {
        expect(
            modelManager.isModelDownloaded(model),
            throwsA(isA<PlatformException>().having(
                (e) => e.toString(), 'message', contains(ERROR_MESSAGE))));
      });

      test('throws exception when fails to get model file', () async {
        expect(
            modelManager.getLatestModelFile(model),
            throwsA(isA<PlatformException>().having(
                (e) => e.toString(), 'message', contains(ERROR_MESSAGE))));
      });
    });
  });
}
