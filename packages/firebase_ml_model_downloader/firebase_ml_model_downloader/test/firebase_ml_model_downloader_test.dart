// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:firebase_ml_model_downloader_platform_interface/firebase_ml_model_downloader_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import './mock.dart';

final MockFirebaseModelDownloader kMockDownloaderPlatform =
    MockFirebaseModelDownloader();

void main() {
  setupFirebaseModelDownloaderMocks();

  late FirebaseModelDownloader mlModelDownloader;
  late FirebaseApp secondaryApp;

  group('$FirebaseModelDownloader', () {
    setUpAll(() async {
      await Firebase.initializeApp();
      secondaryApp = await Firebase.initializeApp(
        name: 'secondaryApp',
        options: const FirebaseOptions(
          appId: '1:1234567890:ios:42424242424242',
          apiKey: '123',
          projectId: '123',
          messagingSenderId: '1234567890',
        ),
      );
      FirebaseModelDownloaderPlatform.instance = MockFirebaseModelDownloader();
      mlModelDownloader = FirebaseModelDownloader.instance;
    });
  });

  group('instance', () {
    test('returns an instance', () async {
      expect(mlModelDownloader, isA<FirebaseModelDownloader>());
    });

    test('returns the correct $FirebaseApp', () {
      expect(mlModelDownloader.app, isA<FirebaseApp>());
      expect(mlModelDownloader.app.name, defaultFirebaseAppName);
    });
  });

  group('instanceFor', () {
    test('returns an instance', () async {
      final mlModelDownloader =
          FirebaseModelDownloader.instanceFor(app: secondaryApp);
      expect(mlModelDownloader, isA<FirebaseModelDownloader>());
    });

    test('returns the correct $FirebaseApp', () {
      final mlModelDownloader =
          FirebaseModelDownloader.instanceFor(app: secondaryApp);
      expect(mlModelDownloader.app, isA<FirebaseApp>());
      expect(mlModelDownloader.app.name, 'secondaryApp');
    });
  });

  group('getModel', () {
    test('verify delegate method is called', () async {
      const String modelName = 'modelName';
      final conditions = FirebaseModelDownloadConditions();
      final customModel = FirebaseCustomModel(
        file: File('file'),
        hash: 'hash',
        name: 'name',
        size: 123,
      );
      when(
        kMockDownloaderPlatform.getModel(
          modelName,
          FirebaseModelDownloadType.latestModel,
          conditions,
        ),
      ).thenAnswer((_) => Future.value(customModel));

      final model = await mlModelDownloader.getModel(
        modelName,
        FirebaseModelDownloadType.latestModel,
        conditions,
      );

      expect(customModel, model);
      verify(
        kMockDownloaderPlatform.getModel(
          modelName,
          FirebaseModelDownloadType.latestModel,
          conditions,
        ),
      );
    });
  });

  group('listDownloadedModels', () {
    test('verify delegate method is called', () async {
      final customModels = [
        FirebaseCustomModel(
          file: File('file'),
          hash: 'hash',
          name: 'name',
          size: 123,
        )
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

final model = FirebaseCustomModel(
  name: 'name',
  size: 100,
  hash: 'hash',
  file: File('path'),
);

class MockFirebaseModelDownloader extends Mock
    with MockPlatformInterfaceMixin
    implements FirebaseModelDownloaderPlatform {
  MockFirebaseModelDownloader() : super();

  @override
  Future<FirebaseCustomModel> getModel(
    String modelName,
    FirebaseModelDownloadType downloadType,
    FirebaseModelDownloadConditions conditions,
  ) {
    return super.noSuchMethod(
      Invocation.method(#getModel, [modelName, downloadType, conditions]),
      returnValue: Future.value(model),
      returnValueForMissingStub: Future.value(model),
    );
  }

  @override
  FirebaseModelDownloaderPlatform delegateFor({FirebaseApp? app}) {
    return super.noSuchMethod(
      Invocation.method(#delegateFor, [], {#app: app}),
      returnValue: kMockDownloaderPlatform,
      returnValueForMissingStub: kMockDownloaderPlatform,
    );
  }

  @override
  Future<List<FirebaseCustomModel>> listDownloadedModels() {
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
