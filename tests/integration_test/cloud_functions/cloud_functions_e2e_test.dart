// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

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
String kTestStreamResponse = 'testStreamResponse';

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
        HttpsCallableResult result = await callable();
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

      test('can be called using an String url', () async {
        final localhostMapped =
            kIsWeb || !Platform.isAndroid ? 'localhost' : '10.0.2.2';

        HttpsCallable callable =
            FirebaseFunctions.instance.httpsCallableFromUrl(
          'http://$localhostMapped:5001/flutterfire-e2e-tests/us-central1/listfruits2ndgen',
        );

        HttpsCallableResult result = await callable();
        expect(result, isA<HttpsCallableResult>());
      });

      test('can be called using an Uri url', () async {
        final localhostMapped =
            kIsWeb || !Platform.isAndroid ? 'localhost' : '10.0.2.2';

        HttpsCallable callable =
            FirebaseFunctions.instance.httpsCallableFromUri(
          Uri.parse(
            'http://$localhostMapped:5001/flutterfire-e2e-tests/us-central1/listfruits2ndgen',
          ),
        );

        HttpsCallableResult result = await callable();
        expect(result, isA<HttpsCallableResult>());
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

      test(
        'allow passing of `limitedUseAppCheckToken` as option',
        () async {
          final instance = FirebaseFunctions.instance;
          instance.useFunctionsEmulator('localhost', 5001);
          final timeoutCallable = FirebaseFunctions.instance.httpsCallable(
            kTestFunctionDefaultRegion,
            options: HttpsCallableOptions(
              timeout: const Duration(seconds: 3),
              limitedUseAppCheckToken: true,
            ),
          );

          HttpsCallableResult results = await timeoutCallable();
          expect(results.data, equals('null'));
        },
      );
    });

    group('HttpsCallable Stream', () {
      test('returns a [StreamResponse]', () {
        final streamResponseCallable =
            FirebaseFunctions.instance.httpsCallable(kTestStreamResponse);
        final stream = streamResponseCallable.stream();
        expect(stream, emits(isA<StreamResponse>()));
      });

      test('accepts a string value', () async {
        final stream = callable.stream('foo').where((event) => event is Chunk);
        await expectLater(
          stream,
          emits(
            isA<Chunk>()
                .having((e) => e.partialData, 'partialData', equals('string')),
          ),
        );
      });

      test('accepts a number value', () async {
        final stream = callable
            .stream(123)
            .where((event) => event is Chunk)
            .asBroadcastStream();
        await expectLater(
          stream,
          emits(
            isA<Chunk>()
                .having((e) => e.partialData, 'partialData', equals('number')),
          ),
        );
      });

      test('accepts no arguments', () async {
        final stream = callable
            .stream()
            .where((event) => event is Chunk)
            .asBroadcastStream();
        await expectLater(
          stream,
          emits(
            isA<Chunk>()
                .having((e) => e.partialData, 'partialData', equals('null')),
          ),
        );
      });

      test('accepts a false boolean value', () async {
        final stream = callable.stream(false).where((event) => event is Chunk);
        await expectLater(
          stream,
          emits(
            isA<Chunk>()
                .having((e) => e.partialData, 'partialData', equals('boolean')),
          ),
        );
      });

      test('accepts a true boolean value', () async {
        final stream = callable.stream(true).where((event) => event is Chunk);
        await expectLater(
          stream,
          emits(
            isA<Chunk>()
                .having((e) => e.partialData, 'partialData', equals('boolean')),
          ),
        );
      });

      test('can be called using an String url', () async {
        final localhostMapped =
            kIsWeb || !Platform.isAndroid ? 'localhost' : '10.0.2.2';

        HttpsCallable callable =
            FirebaseFunctions.instance.httpsCallableFromUrl(
          'http://$localhostMapped:5001/flutterfire-e2e-tests/us-central1/listfruits2ndgen',
        );

        final stream = callable.stream();
        await expectLater(stream, emits(isA<StreamResponse>()));
      });

      test('can be called using an Uri url', () async {
        final localhostMapped =
            kIsWeb || !Platform.isAndroid ? 'localhost' : '10.0.2.2';

        HttpsCallable callable =
            FirebaseFunctions.instance.httpsCallableFromUri(
          Uri.parse(
            'http://$localhostMapped:5001/flutterfire-e2e-tests/us-central1/listfruits2ndgen',
          ),
        );

        final stream = callable.stream();
        await expectLater(stream, emits(isA<StreamResponse>()));
      });

      test('should emit a [Result] as last value', () async {
        final stream = await callable.stream().last;
        expect(
          stream,
          isA<Result>(),
        );
      });

      test('accepts a [List]', () async {
        final stream =
            callable.stream(data.list).where((event) => event is Chunk);
        await expectLater(
          stream,
          emits(
            isA<Chunk>()
                .having((e) => e.partialData, 'partialData', equals('array')),
          ),
        );
      });

      test('accepts a deeply nested [Map]', () async {
        final stream = callable.stream({
          'type': 'deepMap',
          'inputData': data.deepMap,
        }).where((event) => event is Chunk);
        await expectLater(
          stream,
          emits(
            isA<Chunk>().having(
              (e) => e.partialData,
              'partialData',
              equals(data.deepMap),
            ),
          ),
        );
      });

      test(
        'throws error when aborted with TimeLimit signal',
        () async {
          final instance = FirebaseFunctions.instance;
          instance.useFunctionsEmulator('localhost', 5001);

          final completer = Completer<void>();

          final timeoutCallable = FirebaseFunctions.instance.httpsCallable(
            kTestFunctionTimeout,
            options: HttpsCallableOptions(
              webAbortSignal: TimeLimit(const Duration(seconds: 3)),
            ),
          );

          timeoutCallable.stream({
            'testTimeout': const Duration(seconds: 6).inMilliseconds.toString(),
          }).listen(
            (data) {
              completer.completeError('Should have thrown');
            },
            onError: (error) {
              if (error is FirebaseFunctionsException) {
                expect(error.code, equals('internal'));
                completer.complete();
              } else {
                completer.completeError('Unexpected error type: $error');
              }
            },
          );
          await completer.future;
        },
        skip: !kIsWeb,
      );

      test(
        'throws error when aborted with Abort signal',
        () async {
          final instance = FirebaseFunctions.instance;
          instance.useFunctionsEmulator('localhost', 5001);

          final completer = Completer<void>();

          final timeoutCallable = FirebaseFunctions.instance.httpsCallable(
            kTestFunctionTimeout,
            options: HttpsCallableOptions(
              webAbortSignal: Abort('aborted'),
            ),
          );

          timeoutCallable.stream({
            'testTimeout': const Duration(seconds: 6).inMilliseconds.toString(),
          }).listen(
            (data) {
              completer.completeError('Should have thrown');
            },
            onError: (error) {
              if (error is FirebaseFunctionsException) {
                expect(error.code, equals('internal'));
                completer.complete();
              } else {
                completer.completeError('Unexpected error type: $error');
              }
            },
          );
          await completer.future;
        },
        skip: !kIsWeb,
      );
    });
  });
}
