// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$FirebaseApp', () {
    final FirebaseApp testApp = FirebaseApp(
      name: 'testApp',
    );
    const FirebaseOptions testOptions = FirebaseOptions(
      apiKey: 'testAPIKey',
      bundleID: 'testBundleID',
      clientID: 'testClientID',
      trackingID: 'testTrackingID',
      gcmSenderID: 'testGCMSenderID',
      projectID: 'testProjectID',
      androidClientID: 'testAndroidClientID',
      googleAppID: 'testGoogleAppID',
      databaseURL: 'testDatabaseURL',
      deepLinkURLScheme: 'testDeepLinkURLScheme',
      storageBucket: 'testStorageBucket',
    );
    MockFirebaseCore mock;

    setUp(() async {
      mock = MockFirebaseCore();
      FirebaseCorePlatform.instance = mock;

      final PlatformFirebaseApp app = PlatformFirebaseApp(
        'testApp',
        const FirebaseOptions(
          apiKey: 'testAPIKey',
          bundleID: 'testBundleID',
          clientID: 'testClientID',
          trackingID: 'testTrackingID',
          gcmSenderID: 'testGCMSenderID',
          projectID: 'testProjectID',
          androidClientID: 'testAndroidClientID',
          googleAppID: 'testGoogleAppID',
          databaseURL: 'testDatabaseURL',
          deepLinkURLScheme: 'testDeepLinkURLScheme',
          storageBucket: 'testStorageBucket',
        ),
      );

      when(mock.appNamed('testApp')).thenAnswer((_) {
        return Future<PlatformFirebaseApp>.value(app);
      });

      when(mock.allApps()).thenAnswer((_) =>
          Future<List<PlatformFirebaseApp>>.value(<PlatformFirebaseApp>[app]));
    });

    test('configure', () async {
      final FirebaseApp reconfiguredApp = await FirebaseApp.configure(
        name: 'testApp',
        options: testOptions,
      );
      expect(reconfiguredApp, equals(testApp));
      final FirebaseApp newApp = await FirebaseApp.configure(
        name: 'newApp',
        options: testOptions,
      );
      expect(newApp.name, equals('newApp'));
      // It's ugly to specify mockito verification types
      // ignore: always_specify_types
      verifyInOrder([
        mock.appNamed('testApp'),
        mock.appNamed('newApp'),
        mock.configure('newApp', testOptions),
      ]);
    });

    test('appNamed', () async {
      final FirebaseApp existingApp = await FirebaseApp.appNamed('testApp');
      expect(existingApp.name, equals('testApp'));
      expect((await existingApp.options), equals(testOptions));
      final FirebaseApp missingApp = await FirebaseApp.appNamed('missingApp');
      expect(missingApp, isNull);
      // It's ugly to specify mockito verification types
      // ignore: always_specify_types
      verifyInOrder([
        mock.appNamed('testApp'),
        mock.appNamed('testApp'),
        mock.appNamed('missingApp'),
      ]);
    });

    test('allApps', () async {
      final List<FirebaseApp> allApps = await FirebaseApp.allApps();
      expect(allApps, equals(<FirebaseApp>[testApp]));
      verify(mock.allApps());
    });
  });
}

class MockFirebaseCore extends Mock
    with MockPlatformInterfaceMixin
    implements FirebaseCorePlatform {}
