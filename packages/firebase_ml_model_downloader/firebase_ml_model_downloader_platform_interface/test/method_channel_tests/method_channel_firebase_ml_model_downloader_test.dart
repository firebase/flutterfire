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
  setupFirebaseModelDownloaderMocks();

  late FirebaseApp app;
  late FirebaseModelDownloaderPlatform mlDownloader;
  final List<MethodCall> log = <MethodCall>[];

  bool mockPlatformExceptionThrown = false;

  const String kModelName = 'model-name';
  const String kDownloadType = 'latest';

  group('$MethodChannelFirebaseModelDownloader', () {
    setUpAll(() async {
      app = await Firebase.initializeApp();

      handleMethodCall((call) async {
        log.add(call);

        if (mockPlatformExceptionThrown) {
          throw PlatformException(code: 'UNKNOWN');
        }

        switch (call.method) {
          case 'FirebaseModelDownloader#getModel':
            return {
              'filePath': '/path/to/file',
              'size': 1234,
              'name': kModelName,
              'hash': 'model-hash',
            };
          case 'FirebaseModelDownloader#listDownloadedModels':
            return [];
          case 'FirebaseModelDownloader#deleteDownloadedModel':
            return null;
          default:
            return <String, dynamic>{};
        }
      });
    });

    setUp(() {
      log.clear();
      mockPlatformExceptionThrown = false;
      mlDownloader = MethodChannelFirebaseModelDownloader(app: app);
    });

    tearDown(() {
      mockPlatformExceptionThrown = false;
    });

    group('$FirebaseModelDownloaderPlatform()', () {
      test('$MethodChannelFirebaseModelDownloader is the default instance', () {
        expect(
          FirebaseModelDownloaderPlatform.instance,
          isA<MethodChannelFirebaseModelDownloader>(),
        );
      });

      test('Can be extended', () {
        FirebaseModelDownloaderPlatform.instance =
            ExtendsFirebaseModelDownloaderPlatform();
      });

      test('Can be mocked with `implements`', () {
        final FirebaseModelDownloaderPlatform mock =
            MocksFirebaseModelDownloaderPlatform();
        FirebaseModelDownloaderPlatform.instance = mock;
      });
    });

    group('delegateFor', () {
      test('returns correct class instance', () {
        final testMlDownloader =
            TestMethodChannelFirebaseModelDownloader(Firebase.app());
        final result = testMlDownloader.delegateFor(app: Firebase.app());

        expect(result, isA<FirebaseModelDownloaderPlatform>());
        expect(result.app, isA<FirebaseApp>());
      });
    });
    group('getModel', () {
      test('call delegate method successfully', () async {
        final conditions = FirebaseModelDownloadConditions();
        final response = await mlDownloader.getModel(
          kModelName,
          FirebaseModelDownloadType.latestModel,
          conditions,
        );

        expect(response, isA<FirebaseCustomModel>());
        // check native method was called
        expect(log, <Matcher>[
          isMethodCall(
            'FirebaseModelDownloader#getModel',
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
            FirebaseModelDownloadType.latestModel,
            FirebaseModelDownloadConditions(),
          ),
        );
      });
    });

    group('listDownloadedModels', () {
      test('call delegate method successfully', () async {
        final response = await mlDownloader.listDownloadedModels();

        expect(response, isA<List<FirebaseCustomModel>>());
        // check native method was called
        expect(log, <Matcher>[
          isMethodCall(
            'FirebaseModelDownloader#listDownloadedModels',
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
            'FirebaseModelDownloader#deleteDownloadedModel',
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

class MocksFirebaseModelDownloaderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements FirebaseModelDownloaderPlatform {}

class ExtendsFirebaseModelDownloaderPlatform
    extends FirebaseModelDownloaderPlatform {}

class TestMethodChannelFirebaseModelDownloader
    extends MethodChannelFirebaseModelDownloader {
  TestMethodChannelFirebaseModelDownloader(FirebaseApp app) : super(app: app);
}
