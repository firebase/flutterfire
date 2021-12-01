// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:firebase_ml_model_downloader_platform_interface/firebase_ml_model_downloader_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import './mock.dart';

final MockFirebaseMlModelDownloader kMockDownloaderPlatform =
    MockFirebaseMlModelDownloader();

void main() {
  setupFirebaseMlModelDownloaderMocks();

  late FirebaseMlModelDownloader mlModelDownloader;
  late FirebaseApp secondaryApp;

  group('$FirebaseMlModelDownloader', () {
    setUpAll(() async {
      final app = await Firebase.initializeApp();
      secondaryApp = await Firebase.initializeApp(
          name: 'secondaryApp',
          options: const FirebaseOptions(
            appId: '1:1234567890:ios:42424242424242',
            apiKey: '123',
            projectId: '123',
            messagingSenderId: '1234567890',
          ));
      FirebaseMlModelDownloaderPlatform.instance =
          MockFirebaseMlModelDownloader();
      mlModelDownloader = FirebaseMlModelDownloader.instance;
    });
  });

  group('instance', () {
    test('returns an instance', () async {
      expect(mlModelDownloader, isA<FirebaseMlModelDownloader>());
    });

    test('returns the correct $FirebaseApp', () {
      expect(mlModelDownloader.app, isA<FirebaseApp>());
      expect(mlModelDownloader.app.name, defaultFirebaseAppName);
    });
  });

  group('instanceFor', () {
    test('returns an instance', () async {
      final mlModelDownloader =
          FirebaseMlModelDownloader.instanceFor(app: secondaryApp);
      expect(mlModelDownloader, isA<FirebaseMlModelDownloader>());
    });

    test('returns the correct $FirebaseApp', () {
      final mlModelDownloader =
          FirebaseMlModelDownloader.instanceFor(app: secondaryApp);
      expect(mlModelDownloader.app, isA<FirebaseApp>());
      expect(mlModelDownloader.app.name, 'secondaryApp');
    });
  });

  group('getModel', () {
    test('verify delegate method is called', () async {
      const String modelName = 'modelName';
      final conditions = DownloadConditions();
      final customModel = CustomModel(
          file: File('file'), hash: 'hash', name: 'name', size: 123);
      when(kMockDownloaderPlatform.getModel(
              modelName, DownloadType.latestModel, conditions))
          .thenAnswer((_) => Future.value(customModel));

      final model = await mlModelDownloader.getModel(
          modelName, DownloadType.latestModel, conditions);

      expect(customModel, model);
      verify(kMockDownloaderPlatform.getModel(
          modelName, DownloadType.latestModel, conditions));
    });
  });

  group('listDownloadedModels', () {
    test('verify delegate method is called', () async {
      final customModels = [
        CustomModel(file: File('file'), hash: 'hash', name: 'name', size: 123)
      ];
      when(kMockDownloaderPlatform.listDownloadedModels())
          .thenAnswer((_) => Future.value(customModels));

      final modelList = await mlModelDownloader.listDownloadedModels();

      expect(customModels, modelList);
      verify(kMockDownloaderPlatform.listDownloadedModels());
    });
  });

  group('deleteDownloadedModel', () {
    test('verify delegate method is called', () async {
      const String modelName = 'modelName';
      when(kMockDownloaderPlatform.deleteDownloadedModel(modelName))
          .thenAnswer((_) => Future.value());

      await mlModelDownloader.deleteDownloadedModel(modelName);

      verify(kMockDownloaderPlatform.deleteDownloadedModel(modelName));
    });
  });
}

final model =
    CustomModel(name: 'name', size: 100, hash: 'hash', file: File('path'));

class MockFirebaseMlModelDownloader extends Mock
    with MockPlatformInterfaceMixin
    implements FirebaseMlModelDownloaderPlatform {
  MockFirebaseMlModelDownloader() : super();

  @override
  Future<CustomModel> getModel(
    String modelName,
    DownloadType downloadType,
    DownloadConditions conditions,
  ) {
    return super.noSuchMethod(
      Invocation.method(#getModel, [modelName, downloadType, conditions]),
      returnValue: Future.value(model),
      returnValueForMissingStub: Future.value(model),
    );
  }

  @override
  FirebaseMlModelDownloaderPlatform delegateFor({FirebaseApp? app}) {
    return super.noSuchMethod(
      Invocation.method(#delegateFor, [], {#app: app}),
      returnValue: kMockDownloaderPlatform,
      returnValueForMissingStub: kMockDownloaderPlatform,
    );
  }

  @override
  Future<List<CustomModel>> listDownloadedModels() {
    return super.noSuchMethod(
      Invocation.method(#listDownloadedModels, []),
      returnValue: Future.value([model]),
      returnValueForMissingStub: Future.value([model]),
    );
  }

  @override
  Future<void> deleteDownloadedModel(String modelName) {
    return super.noSuchMethod(
      Invocation.method(#deleteDownloadedModel, [modelName]),
      returnValue: Future.value(),
      returnValueForMissingStub: Future.value(),
    );
  }
}
