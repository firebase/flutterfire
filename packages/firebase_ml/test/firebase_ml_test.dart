// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_ml/firebase_ml.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  String MODEL_NAME = "myModelName";
  String MODEL_HASH = "myModelHash";
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
            var model = <String, String>{};
            model['modelName'] = MODEL_NAME;
            model['modelHash'] = MODEL_HASH;
            return model;
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

    test('valid sequence of calls', () async {
      expect(modelManager, isNotNull);
      FirebaseCustomRemoteModel model = FirebaseCustomRemoteModel(MODEL_NAME);
      expect(model.modelHash, isNull);
      FirebaseModelDownloadConditions conditions =
          FirebaseModelDownloadConditions(requireWifi: true);
      expect(conditions, isNotNull);

      await modelManager.download(model, conditions);
      expect(model.modelName, MODEL_NAME);
      expect(model.modelHash, MODEL_HASH);

      var isModelDownloaded = await modelManager.isModelDownloaded(model);
      expect(isModelDownloaded, isTrue);

      var modelFile = await modelManager.getLatestModelFile(model);
      expect(modelFile.path, MODEL_FILE_PATH);

      expect(
        log,
        <Matcher>[
          isMethodCall(
            'FirebaseModelManager#download',
            arguments: <String, dynamic>{
              'model': MODEL_NAME,
              'conditions': conditions.toMap(),
            },
          ),
          isMethodCall(
            'FirebaseModelManager#isModelDownloaded',
            arguments: <String, dynamic>{
              'model': MODEL_NAME,
            },
          ),
          isMethodCall(
            'FirebaseModelManager#getLatestModelFile',
            arguments: <String, dynamic>{
              'model': MODEL_NAME,
            },
          ),
        ],
      );
    });
  });
}
