// @dart = 2.9

// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart=2.9

import 'package:cloud_functions/cloud_functions.dart';
import 'package:drive/drive.dart' as drive;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sample.dart' as data;

String kTestFunctionDefaultRegion = 'testFunctionDefaultRegion';
String kTestFunctionCustomRegion = 'testFunctionCustomRegion';
String kTestFunctionTimeout = 'testFunctionTimeout';

void testsMain() {
  HttpsCallable callable;
  setUpAll(() async {
    await Firebase.initializeApp();
    FirebaseFunctions.instance
        .useFunctionsEmulator(origin: 'http://localhost:5001');
    callable =
        FirebaseFunctions.instance.httpsCallable(kTestFunctionDefaultRegion);
  });

  group('HttpsCallable', () {
    test('returns a [HttpsCallableResult]', () async {
      var result = await callable();
      expect(result, isA<HttpsCallableResult>());
    });

    test('accepts no arguments', () async {
      HttpsCallableResult result = await callable();
      expect(result.data, equals('null'));
    });

    test('accepts `null arguments', () async {
      HttpsCallableResult result = await callable(null);
      expect(result.data, equals('null'));
    });

    test('accepts a string value', () async {
      HttpsCallableResult result = await callable('foo');
      expect(result.data, equals('string'));
    });

    test('accepts a number value', () async {
      HttpsCallableResult result = await callable(123);
      expect(result.data, equals('number'));
      HttpsCallableResult result2 = await callable(12.3);
      expect(result2.data, equals('number'));
    });

    test('accepts a boolean value', () async {
      HttpsCallableResult result = await callable(true);
      expect(result.data, equals('boolean'));
      HttpsCallableResult result2 = await callable(false);
      expect(result2.data, equals('boolean'));
    });

    test('accepts a [List]', () async {
      HttpsCallableResult result = await callable(data.list);
      expect(result.data, equals('array'));
    });

    test('accepts a deeply nested [Map]', () async {
      HttpsCallableResult result = await callable({
        'type': 'deepMap',
        'inputData': data.deepMap,
      });
      expect(result.data, equals(data.deepMap));
    });

    test('accepts a deeply nested [List]', () async {
      HttpsCallableResult result = await callable({
        'type': 'deepList',
        'inputData': data.deepList,
      });
      expect(result.data, equals(data.deepList));
    });
  });

  group('FirebaseFunctionsException', () {
    test('HttpsCallable returns a FirebaseFunctionsException on error',
        () async {
      try {
        await callable({});
        fail('Should have thrown');
      } on FirebaseFunctionsException catch (e) {
        expect(e.code, equals('invalid-argument'));
        expect(e.message, equals('Invalid test requested.'));
        return;
      } catch (e) {
        fail(e);
      }
    });

    test('it returns "details" value as part of the exception', () async {
      try {
        await callable({
          'type': 'deepMap',
          'inputData': data.deepMap,
          'asError': true,
        });
        fail('Should have thrown');
      } on FirebaseFunctionsException catch (e) {
        expect(e.code, equals('cancelled'));
        expect(
            e.message,
            equals(
                'Response data was requested to be sent as part of an Error payload, so here we are!'));
        expect(e.details, equals(data.deepMap));
      } catch (e) {
        fail(e);
      }
    });
  });

  group('region', () {
    HttpsCallable customRegionCallable;
    setUpAll(() async {
      customRegionCallable =
          FirebaseFunctions.instanceFor(region: 'europe-west1')
              .httpsCallable(kTestFunctionCustomRegion);
    });

    test('uses a non-default region', () async {
      HttpsCallableResult result = await customRegionCallable();
      expect(result.data, equals('europe-west1'));
    });
  });

  group('HttpsCallableOptions', () {
    HttpsCallable timeoutCallable;

    setUpAll(() async {
      timeoutCallable = FirebaseFunctions.instance.httpsCallable(
          kTestFunctionTimeout,
          options: HttpsCallableOptions(timeout: const Duration(seconds: 3)));
    });

    test('times out when the provided timeout is exceeded', () async {
      try {
        await timeoutCallable({
          'testTimeout': const Duration(seconds: 6).inMilliseconds.toString(),
        });
        fail('Should have thrown');
      } on FirebaseFunctionsException catch (e) {
        expect(e.code, equals('deadline-exceeded'));
      } catch (e) {
        fail(e);
      }
    });
  });
}

void main() => drive.main(testsMain);
