// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_ml_model_downloader_platform_interface/firebase_ml_model_downloader_platform_interface.dart';
import 'package:firebase_ml_model_downloader_platform_interface/src/method_channel/method_channel_firebase_ml_model_downloader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../mock.dart';

void main() {
  setupFirebaseMlModelDownloaderMocks();

  late FirebaseApp app;
  late FirebaseMlModelDownloaderPlatform mlDownloader;
  final List<MethodCall> log = <MethodCall>[];

  bool mockPlatformExceptionThrown = false;

  const String kModelName = 'model-name';
  const String kDownloadType = 'latest';

  group('$MethodChannelFirebaseMlModelDownloader', () {
    setUpAll(() async {
      app = await Firebase.initializeApp();

      handleMethodCall((call) async {
        log.add(call);

        if (mockPlatformExceptionThrown) {
          throw PlatformException(code: 'UNKNOWN');
        }

        switch (call.method) {
          case 'FirebaseMlModelDownloader#getModel':
            return {
              'filePath': '/path/to/file',
              'size': 1234,
              'name': kModelName,
              'hash': 'model-hash',
            };
          case 'FirebaseMlModelDownloader#listDownloadedModels':
            return [];
          case 'FirebaseMlModelDownloader#deleteDownloadedModel':
            return null;
          default:
            return <String, dynamic>{};
        }
      });
    });

    setUp(() {
      log.clear();
      mockPlatformExceptionThrown = false;
      mlDownloader = MethodChannelFirebaseMlModelDownloader(app: app);
    });

    tearDown(() {
      mockPlatformExceptionThrown = false;
    });

    group('$FirebaseMlModelDownloaderPlatform()', () {
      test('$MethodChannelFirebaseMlModelDownloader is the default instance',
          () {
        expect(
          FirebaseMlModelDownloaderPlatform.instance,
          isA<MethodChannelFirebaseMlModelDownloader>(),
        );
      });

      test('Can be extended', () {
        FirebaseMlModelDownloaderPlatform.instance =
            ExtendsFirebaseMlModelDownloaderPlatform();
      });

      test('Can be mocked with `implements`', () {
        final FirebaseMlModelDownloaderPlatform mock =
            MocksFirebaseMlModelDownloaderPlatform();
        FirebaseMlModelDownloaderPlatform.instance = mock;
      });
    });

    group('delegateFor', () {
      test('returns correct class instance', () {
        final testMlDownloader =
            TestMethodChannelFirebaseMlModelDownloader(Firebase.app());
        final result = testMlDownloader.delegateFor(app: Firebase.app());

        expect(result, isA<FirebaseMlModelDownloaderPlatform>());
        expect(result.app, isA<FirebaseApp>());
      });
    });
    group('getModel', () {
      test('call delegate method successfully', () async {
        final conditions = DownloadConditions();
        final response = await mlDownloader.getModel(
          kModelName,
          DownloadType.latestModel,
          conditions,
        );

        expect(response, isA<CustomModel>());
        // check native method was called
        expect(log, <Matcher>[
          isMethodCall(
            'FirebaseMlModelDownloader#getModel',
            arguments: <String, dynamic>{
              'appName': app.name,
              'modelName': kModelName,
              'downloadType': kDownloadType,
              'conditions': conditions.toMap(),
            },
          ),
        ]);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseException] error',
          () async {
        mockPlatformExceptionThrown = true;

        await testExceptionHandling(
          'PLATFORM',
          () => mlDownloader.getModel(
            kModelName,
            DownloadType.latestModel,
            DownloadConditions(),
          ),
        );
      });
    });

    group('listDownloadedModels', () {
      test('call delegate method successfully', () async {
        final response = await mlDownloader.listDownloadedModels();

        expect(response, isA<List<CustomModel>>());
        // check native method was called
        expect(log, <Matcher>[
          isMethodCall(
            'FirebaseMlModelDownloader#listDownloadedModels',
            arguments: <String, dynamic>{
              'appName': app.name,
            },
          ),
        ]);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseException] error',
          () async {
        mockPlatformExceptionThrown = true;

        await testExceptionHandling(
          'PLATFORM',
          () => mlDownloader.listDownloadedModels(),
        );
      });
    });

    group('deleteDownloadedModel', () {
      test('call delegate method successfully', () async {
        await mlDownloader.deleteDownloadedModel(kModelName);

        // check native method was called
        expect(log, <Matcher>[
          isMethodCall(
            'FirebaseMlModelDownloader#deleteDownloadedModel',
            arguments: <String, dynamic>{
              'appName': app.name,
              'modelName': kModelName,
            },
          ),
        ]);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseException] error',
          () async {
        mockPlatformExceptionThrown = true;

        await testExceptionHandling(
          'PLATFORM',
          () => mlDownloader.deleteDownloadedModel(kModelName),
        );
      });
    });
  });
}

class MocksFirebaseMlModelDownloaderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements FirebaseMlModelDownloaderPlatform {}

class ExtendsFirebaseMlModelDownloaderPlatform
    extends FirebaseMlModelDownloaderPlatform {}

class TestMethodChannelFirebaseMlModelDownloader
    extends MethodChannelFirebaseMlModelDownloader {
  TestMethodChannelFirebaseMlModelDownloader(FirebaseApp app) : super(app: app);
}
