// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_dynamic_links_platform_interface/firebase_dynamic_links_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../mock.dart';

void main() {
  setupFirebaseDynamicLinksMocks();

  TestFirebaseDynamicLinksPlatform? firebaseDynamicLinksPlatformPlatform;

  FirebaseApp? app;
  FirebaseApp? secondaryApp;
  final link = Uri.parse('uri');
  final parameters = DynamicLinkParameters(uriPrefix: '', link: link);

  group('$FirebaseDynamicLinksPlatform()', () {
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

      firebaseDynamicLinksPlatformPlatform = TestFirebaseDynamicLinksPlatform(
        app!,
      );
    });

    test('Constructor', () {
      expect(
        firebaseDynamicLinksPlatformPlatform,
        isA<FirebaseDynamicLinksPlatform>(),
      );
      expect(firebaseDynamicLinksPlatformPlatform, isA<PlatformInterface>());
    });

    test('get.instance', () {
      expect(
        FirebaseDynamicLinksPlatform.instance,
        isA<FirebaseDynamicLinksPlatform>(),
      );
      expect(
        FirebaseDynamicLinksPlatform.instance.app.name,
        equals(defaultFirebaseAppName),
      );
    });

    group('set.instance', () {
      test('sets the current instance', () {
        FirebaseDynamicLinksPlatform.instance =
            TestFirebaseDynamicLinksPlatform(secondaryApp!);

        expect(
          FirebaseDynamicLinksPlatform.instance,
          isA<FirebaseDynamicLinksPlatform>(),
        );
        expect(
          FirebaseDynamicLinksPlatform.instance.app.name,
          equals('testApp2'),
        );
      });
    });

    test('throws if .getInitialLink', () {
      expect(
        () => firebaseDynamicLinksPlatformPlatform!.getInitialLink(),
        throwsA(
          isA<UnimplementedError>().having(
            (e) => e.message,
            'message',
            'getInitialLink() is not implemented',
          ),
        ),
      );
    });

    test('throws if .getDynamicLink', () {
      expect(
        () => firebaseDynamicLinksPlatformPlatform!.getDynamicLink(link),
        throwsA(
          isA<UnimplementedError>().having(
            (e) => e.message,
            'message',
            'getDynamicLink() is not implemented',
          ),
        ),
      );
    });

    test('throws if .onLink', () {
      expect(
        () => firebaseDynamicLinksPlatformPlatform!.onLink,
        throwsA(
          isA<UnimplementedError>().having(
            (e) => e.message,
            'message',
            'onLink is not implemented',
          ),
        ),
      );
    });

    test('throws if .buildLink', () {
      expect(
        () => firebaseDynamicLinksPlatformPlatform!.buildLink(parameters),
        throwsA(
          isA<UnimplementedError>().having(
            (e) => e.message,
            'message',
            'buildLink() is not implemented',
          ),
        ),
      );
    });

    test('throws if .buildShortLink', () {
      expect(
        () => firebaseDynamicLinksPlatformPlatform!.buildShortLink(parameters),
        throwsA(
          isA<UnimplementedError>().having(
            (e) => e.message,
            'message',
            'buildShortLink() is not implemented',
          ),
        ),
      );
    });
  });
}

class TestFirebaseDynamicLinksPlatform extends FirebaseDynamicLinksPlatform {
  TestFirebaseDynamicLinksPlatform(FirebaseApp app) : super(appInstance: app);
}
