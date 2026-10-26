// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:dart_cloud_functions/dart_cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// The firebase_core test mocks give every app this project ID.
const _mockProjectId = '123';

Matcher _throwsCode(String code) {
  return throwsA(
    isA<DartFirebaseFunctionsException>().having((e) => e.code, 'code', code),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  late FirebaseApp app;

  setUpAll(() async {
    app = await Firebase.initializeApp();
  });

  // Flutter tests run as Android by default, so only the
  // useFunctionsEmulator() tests turn on the Android host mapping.
  DartFirebaseFunctions emulatorFunctions(
    MockClientHandler handler, {
    bool automaticHostMapping = false,
  }) {
    return DartFirebaseFunctions.withHttpClient(MockClient(handler), app: app)
      ..useFunctionsEmulator(
        'localhost',
        5001,
        automaticHostMapping: automaticHostMapping,
      );
  }

  group('instanceFor()', () {
    test('returns one cached instance per app and region', () {
      expect(
        DartFirebaseFunctions.instanceFor(app: app),
        same(DartFirebaseFunctions.instance),
      );
      expect(
        DartFirebaseFunctions.instanceFor(app: app, region: 'europe-west1'),
        isNot(same(DartFirebaseFunctions.instance)),
      );
    });
  });

  group('DartHttpsCallable.call()', () {
    test('posts a callable request and returns the result', () async {
      late http.Request sent;
      final functions = emulatorFunctions((request) async {
        sent = request;
        return http.Response('{"result":["Apple"]}', 200);
      });

      final result = await functions.httpsCallable('listFruit').call({'n': 1});

      expect(result.data, ['Apple']);
      expect(sent.method, 'POST');
      expect(
        sent.url.toString(),
        'http://localhost:5001/$_mockProjectId/us-central1/listFruit',
      );
      expect(sent.headers['Content-Type'], startsWith('application/json'));
      expect(jsonDecode(sent.body), {
        'data': {'n': 1},
      });
    });

    test('uses a callable URL as is', () async {
      late Uri sentUrl;
      final functions = emulatorFunctions((request) async {
        sentUrl = request.url;
        return http.Response('{"result":null}', 200);
      });

      await functions
          .httpsCallableFromUrl('https://listfruits-abc123-uc.a.run.app')
          .call();

      expect(sentUrl.toString(), 'https://listfruits-abc123-uc.a.run.app');
    });

    test('throws the error from an HttpsError envelope', () async {
      final functions = emulatorFunctions((_) async {
        return http.Response(
          '{"error":{"message":"Nope.","status":"PERMISSION_DENIED"}}',
          403,
        );
      });

      await expectLater(
        functions.httpsCallable('listFruit').call(),
        throwsA(
          isA<DartFirebaseFunctionsException>()
              .having((e) => e.code, 'code', 'permission-denied')
              .having((e) => e.message, 'message', 'Nope.')
              .having((e) => e.plugin, 'plugin', 'dart_cloud_functions'),
        ),
      );
    });

    test('maps a timeout to deadline-exceeded', () async {
      final never = Completer<http.Response>();
      final functions = emulatorFunctions((_) => never.future);

      await expectLater(
        functions
            .httpsCallable(
              'listFruit',
              options: const DartHttpsCallableOptions(
                timeout: Duration(milliseconds: 10),
              ),
            )
            .call(),
        _throwsCode('deadline-exceeded'),
      );
    });

    test('maps a network failure to unavailable', () async {
      final functions = emulatorFunctions((request) async {
        throw http.ClientException('Connection refused', request.url);
      });

      await expectLater(
        functions.httpsCallable('listFruit').call(),
        _throwsCode('unavailable'),
      );
    });
  });

  group('useFunctionsEmulator()', () {
    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    Future<Uri> sentUrlOn(TargetPlatform platform) async {
      debugDefaultTargetPlatformOverride = platform;
      late Uri sentUrl;
      final functions = emulatorFunctions(
        (request) async {
          sentUrl = request.url;
          return http.Response('{"result":null}', 200);
        },
        automaticHostMapping: true,
      );
      await functions.httpsCallable('listFruit').call();
      return sentUrl;
    }

    test('maps localhost to 10.0.2.2 on Android', () async {
      expect((await sentUrlOn(TargetPlatform.android)).host, '10.0.2.2');
    });

    test('keeps localhost on other platforms', () async {
      expect((await sentUrlOn(TargetPlatform.macOS)).host, 'localhost');
    });
  });
}
