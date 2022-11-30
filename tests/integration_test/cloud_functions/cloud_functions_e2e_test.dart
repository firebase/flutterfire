// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tests/firebase_options.dart';

import 'sample_data.dart' as data;

String kTestFunctionDefaultRegion = 'testFunctionDefaultRegion';
String kTestFunctionCustomRegion = 'testFunctionCustomRegion';
String kTestFunctionTimeout = 'testFunctionTimeout';
String kTestMapConvertType = 'testMapConvertType';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('cloud_functions', () {
    late HttpsCallable callable;

    setUpAll(() async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
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

      test(
        'accepts raw data as arguments',
        () async {
          HttpsCallableResult result = await callable({
            'type': 'rawData',
            'list': Uint8List(100),
            'int': Int32List(39),
            'long': Int64List(45),
            'float': Float32List(23),
            'double': Float64List(1001),
          });
          final data = result.data;
          expect(data['list'], isA<List>());
          expect(data['int'], isA<List>());
          expect(data['long'], isA<List>());
          expect(data['float'], isA<List>());
          expect(data['double'], isA<List>());
        },
        // Int64List is not supported on Web.
        skip: kIsWeb,
      );

      test(
        '[HttpsCallableResult.data] should return Map<String, dynamic> type for returned objects',
        () async {
          HttpsCallable callable =
              FirebaseFunctions.instance.httpsCallable(kTestMapConvertType);

          var result = await callable();

          expect(result.data, isA<Map<String, dynamic>>());
        },
      );
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
          fail('$e');
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
              'Response data was requested to be sent as part of an Error payload, so here we are!',
            ),
          );
          expect(e.details, equals(data.deepMap));
        } catch (e) {
          fail('$e');
        }
      });
    });

    group('instanceFor', () {
      test('accepts a custom region', () async {
        final instance = FirebaseFunctions.instanceFor(region: 'europe-west1');
        instance.useFunctionsEmulator('localhost', 5001);
        final customRegionCallable =
            instance.httpsCallable(kTestFunctionCustomRegion);
        final result = await customRegionCallable();
        expect(result.data, equals('europe-west1'));
      });
    });

    group('HttpsCallableOptions', () {
      test(
        'times out when the provided timeout option is exceeded',
        () async {
          final instance = FirebaseFunctions.instance;
          instance.useFunctionsEmulator('localhost', 5001);
          final timeoutCallable = FirebaseFunctions.instance.httpsCallable(
            kTestFunctionTimeout,
            options: HttpsCallableOptions(timeout: const Duration(seconds: 3)),
          );
          try {
            await timeoutCallable({
              'testTimeout':
                  const Duration(seconds: 6).inMilliseconds.toString(),
            });
            fail('Should have thrown');
          } on FirebaseFunctionsException catch (e) {
            expect(e.code, equals('deadline-exceeded'));
          } catch (e) {
            fail('$e');
          }
        },
        // Android skip because it's flaky. See:
        // https://github.com/firebase/flutterfire/issues/9652
        skip: defaultTargetPlatform == TargetPlatform.android,
      );
    });
  });
}
