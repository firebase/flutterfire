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

  group('$FirebaseModelManager', () {
    final List<MethodCall> log = <MethodCall>[];
    final FirebaseModelManager modelManager = FirebaseModelManager.instance;

    setUp(() {
      FirebaseModelManager.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);

        switch (methodCall.method) {
          case 'FirebaseModelManager#download':
            return "Success";
          case 'FirebaseModelManager#getLatestModelFile':
            return MODEL_FILE_PATH;
          case 'FirebaseModelManager#isModelDownloaded':
            return true;
          default:
            return null;
        }
      });
      log.clear();
    });

    tearDown(() {
      FirebaseModelManager.channel.setMockMethodCallHandler(null);
    });
    test('condition constructor defaults to right values', () async {
      FirebaseModelDownloadConditions conditions =
          FirebaseModelDownloadConditions();
      expect(conditions.androidRequireWifi, false);
      expect(conditions.androidRequireDeviceIdle, false);
      expect(conditions.androidRequireCharging, false);
      expect(conditions.iosAllowBackgroundDownloading, false);
      expect(conditions.iosAllowCellularAccess, true);
    });
    test('manager downloads model', () async {
      expect(modelManager, isNotNull);
      FirebaseCustomRemoteModel model = FirebaseCustomRemoteModel(MODEL_NAME);
      FirebaseModelDownloadConditions conditions =
          FirebaseModelDownloadConditions(androidRequireWifi: true);
      expect(conditions, isNotNull);

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
      expect(modelManager, isNotNull);
      FirebaseCustomRemoteModel model = FirebaseCustomRemoteModel(MODEL_NAME);

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
      expect(modelManager, isNotNull);
      FirebaseCustomRemoteModel model = FirebaseCustomRemoteModel(MODEL_NAME);

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
}
