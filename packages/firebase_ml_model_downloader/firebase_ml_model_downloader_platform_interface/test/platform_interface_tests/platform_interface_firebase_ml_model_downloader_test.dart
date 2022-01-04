// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ml_model_downloader_platform_interface/firebase_ml_model_downloader_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../mock.dart';

void main() {
  setupFirebaseModelDownloaderMocks();

  late TestFirebaseModelDownloaderPlatform firebaseModelDownloaderPlatform;
  late FirebaseApp app;
  late FirebaseApp secondaryApp;

  group('$FirebaseModelDownloaderPlatform()', () {
    setUpAll(() async {
      app = await Firebase.initializeApp();

      secondaryApp = await Firebase.initializeApp(
        name: 'testApp2',
        options: const FirebaseOptions(
          appId: '1:1234567890:ios:42424242424242',
          apiKey: '123',
          projectId: '123',
          messagingSenderId: '1234567890',
        ),
      );

      firebaseModelDownloaderPlatform = TestFirebaseModelDownloaderPlatform(
        app,
      );

      handleMethodCall((call) async {
        switch (call.method) {
          default:
            return null;
        }
      });
    });

    test('Constructor', () {
      expect(
        firebaseModelDownloaderPlatform,
        isA<FirebaseModelDownloaderPlatform>(),
      );
      expect(firebaseModelDownloaderPlatform, isA<PlatformInterface>());
    });

    test('instanceFor', () {
      final result = FirebaseModelDownloaderPlatform.instanceFor(
        app: app,
      );
      expect(result, isA<FirebaseModelDownloaderPlatform>());
    });

    test('get.instance', () {
      expect(
        FirebaseModelDownloaderPlatform.instance,
        isA<FirebaseModelDownloaderPlatform>(),
      );
      expect(
        FirebaseModelDownloaderPlatform.instance.app.name,
        equals(defaultFirebaseAppName),
      );
    });

    group('set.instance', () {
      test('sets the current instance', () {
        FirebaseModelDownloaderPlatform.instance =
            TestFirebaseModelDownloaderPlatform(secondaryApp);

        expect(
          FirebaseModelDownloaderPlatform.instance,
          isA<FirebaseModelDownloaderPlatform>(),
        );
        expect(
          FirebaseModelDownloaderPlatform.instance.app.name,
          equals('testApp2'),
        );
      });
    });

    test('throws if delegateFor', () {
      expect(
        () => firebaseModelDownloaderPlatform.testDelegateFor(),
        throwsA(
          isA<UnimplementedError>().having(
            (e) => e.message,
            'message',
            'delegateFor() is not implemented',
          ),
        ),
      );
    });

    test('throws if getModel', () {
      expect(
        () => firebaseModelDownloaderPlatform.getModel(
          'modelName',
          FirebaseModelDownloadType.latestModel,
          FirebaseModelDownloadConditions(),
        ),
        throwsA(
          isA<UnimplementedError>().having(
            (e) => e.message,
            'message',
            'getModel() is not implemented',
          ),
        ),
      );
    });

    test('throws if listDownloadedModels', () {
      expect(
        () => firebaseModelDownloaderPlatform.listDownloadedModels(),
        throwsA(
          isA<UnimplementedError>().having(
            (e) => e.message,
            'message',
            'listDownloadedModels() is not implemented',
          ),
        ),
      );
    });

    test('throws if deleteDownloadedModel', () {
      expect(
        () =>
            firebaseModelDownloaderPlatform.deleteDownloadedModel('modelName'),
        throwsA(
          isA<UnimplementedError>().having(
            (e) => e.message,
            'message',
            'deleteDownloadedModel() is not implemented',
          ),
        ),
      );
    });
  });
}

class TestFirebaseModelDownloaderPlatform
    extends FirebaseModelDownloaderPlatform {
  TestFirebaseModelDownloaderPlatform(FirebaseApp? app)
      : super(appInstance: app);

  FirebaseModelDownloaderPlatform testDelegateFor({FirebaseApp? app}) {
    return delegateFor(app: app ?? Firebase.app());
  }
}
