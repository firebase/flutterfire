// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_functions_example/emulator_config.dart';
import 'package:cloud_functions_example/firebase_options.dart';
import 'package:dart_cloud_functions/dart_cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'report_test_results.dart';
import 'sample_data.dart' as data;

/// The `call()` and `stream()` cases from `e2e_test.dart`, run against
/// `dart_cloud_functions`.
///
/// Keep the two files in step until they share one suite (plan item 0.3).
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  reportTestResultsToDriver(binding);

  group('dart_cloud_functions', () {
    late DartFirebaseFunctions functions;
    late DartHttpsCallable callable;

    setUpAll(() async {
      // Same guard as e2e_test.dart: the native SDK may already have
      // configured [DEFAULT] from the bundled GoogleService-Info.plist.
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } on FirebaseException catch (e) {
        if (e.code != 'duplicate-app') {
          rethrow;
        }
      }
      functions = DartFirebaseFunctions.instance;
      connectDartFunctionsEmulator(functions);
      await connectAuthEmulatorAndSignOut();
      callable = functions.httpsCallable('testFunctionDefaultRegion');
    });

    group('DartHttpsCallable.call()', () {
      test('returns a [DartHttpsCallableResult]', () async {
        expect(await callable.call(), isA<DartHttpsCallableResult>());
      });

      test('accepts no arguments', () async {
        expect((await callable.call()).data, 'null');
      });

      test('accepts a string value', () async {
        expect((await callable.call('foo')).data, 'string');
      });

      test('accepts a number value', () async {
        expect((await callable.call(123)).data, 'number');
        expect((await callable.call(12.3)).data, 'number');
      });

      test('accepts a boolean value', () async {
        expect((await callable.call(true)).data, 'boolean');
        expect((await callable.call(false)).data, 'boolean');
      });

      test('accepts a [List]', () async {
        expect((await callable.call(data.list)).data, 'array');
      });

      test('accepts a deeply nested [Map]', () async {
        final result = await callable.call({
          'type': 'deepMap',
          'inputData': data.deepMap,
        });
        expect(result.data, data.deepMap);
      });

      test('accepts a deeply nested [List]', () async {
        final result = await callable.call({
          'type': 'deepList',
          'inputData': data.deepList,
        });
        expect(result.data, data.deepList);
      });

      test('accepts raw data as arguments', () async {
        final result = await callable.call<Map<String, dynamic>>({
          'type': 'rawData',
          'list': Uint8List(100),
          'int': Int32List(39),
          // Int64List is not supported by dart2js.
          if (!kIsWeb) 'long': Int64List(45),
          'float': Float32List(23),
          'double': Float64List(1001),
        });
        for (final key in ['list', 'int', 'float', 'double']) {
          expect(result.data[key], isA<List>());
        }
      });

      test('returns objects as Map<String, dynamic>', () async {
        final result =
            await functions.httpsCallable('testMapConvertType').call();
        expect(result.data, isA<Map<String, dynamic>>());
      });

      test('can be called using a String url', () async {
        final result =
            await functions.httpsCallableFromUrl(_listFruits2ndGenUrl).call();
        expect(result.data, data.fruits);
      });

      test('can be called using a Uri', () async {
        final result = await functions
            .httpsCallableFromUri(Uri.parse(_listFruits2ndGenUrl))
            .call();
        expect(result.data, data.fruits);
      });
    });

    group('DartHttpsCallable.stream()', () {
      // Like the native suite, most cases look at the first chunk.
      Future<Object?> firstChunk(DartHttpsCallable callable, [Object? input]) {
        return callable
            .stream<Object?, Object?>(input)
            .where((response) => response is DartChunk)
            .map((response) => (response as DartChunk).partialData)
            .first;
      }

      test('returns a [DartStreamResponse]', () async {
        await expectLater(
          functions.httpsCallable('testStreamResponse').stream(),
          emits(isA<DartStreamResponse>()),
        );
      });

      test('streams the chunks, then the result', () async {
        final responses = await functions
            .httpsCallable('testStreamResponse')
            .stream<String, List<dynamic>>()
            .toList();

        expect(
          [
            for (final response in responses)
              if (response case DartChunk(:final partialData)) partialData,
          ],
          ['Apple', 'Mango', 'Banana'],
        );
        expect(
          responses.last,
          isA<DartResult<String, List<dynamic>>>().having(
            (r) => r.result.data,
            'data',
            ['Apple', 'Mango', 'Banana'],
          ),
        );
      });

      test('accepts a string value', () async {
        expect(await firstChunk(callable, 'foo'), 'string');
      });

      test('accepts a number value', () async {
        expect(await firstChunk(callable, 123), 'number');
      });

      test('accepts no arguments', () async {
        expect(await firstChunk(callable), 'null');
      });

      test('accepts a false boolean value', () async {
        expect(await firstChunk(callable, false), 'boolean');
      });

      test('accepts a true boolean value', () async {
        expect(await firstChunk(callable, true), 'boolean');
      });

      test('accepts a [List]', () async {
        expect(await firstChunk(callable, data.list), 'array');
      });

      test('accepts a deeply nested [Map]', () async {
        expect(
          await firstChunk(callable, {
            'type': 'deepMap',
            'inputData': data.deepMap,
          }),
          data.deepMap,
        );
      });

      test('can be called using a String url', () async {
        await expectLater(
          functions.httpsCallableFromUrl(_listFruits2ndGenUrl).stream(),
          emits(isA<DartStreamResponse>()),
        );
      });

      test('can be called using a Uri', () async {
        await expectLater(
          functions
              .httpsCallableFromUri(Uri.parse(_listFruits2ndGenUrl))
              .stream(),
          emits(isA<DartStreamResponse>()),
        );
      });

      test('sends data when called using a url', () async {
        final byUrl = functions.httpsCallableFromUrl(
          _testFunctionDefaultRegionUrl,
        );
        expect(await firstChunk(byUrl, 'foo'), 'string');
      });

      test('concurrent streams on the same callable do not collide', () async {
        final results = await Future.wait([
          firstChunk(callable, 'foo'),
          firstChunk(callable, 123),
        ]);
        expect(results, ['string', 'number']);
      });

      test('emits a [DartResult] as the last value', () async {
        expect(await callable.stream().last, isA<DartResult>());
      });

      test('returns objects in the result as Map<String, dynamic>', () async {
        final last = await callable.stream({
          'type': 'deepMap',
          'inputData': data.deepMap,
        }).last;
        expect((last as DartResult).result.data, isA<Map<String, dynamic>>());
      });

      test('emits an error the function throws', () async {
        await expectLater(
          callable.stream({}),
          emitsError(
            isA<DartFirebaseFunctionsException>()
                .having((e) => e.code, 'code', 'invalid-argument')
                .having((e) => e.message, 'message', 'Invalid test requested.'),
          ),
        );
      });

      test(
        'fails with deadline-exceeded when nothing arrives for the timeout',
        () async {
          final timeoutCallable = functions.httpsCallable(
            'testFunctionTimeout',
            options:
                const DartHttpsCallableOptions(timeout: Duration(seconds: 3)),
          );
          await expectLater(
            timeoutCallable.stream({
              'testTimeout':
                  const Duration(seconds: 6).inMilliseconds.toString(),
            }),
            emitsError(
              isA<DartFirebaseFunctionsException>()
                  .having((e) => e.code, 'code', 'deadline-exceeded'),
            ),
          );
        },
        // Web streams have no timeout, as in the JS SDK.
        skip: kIsWeb,
      );
    });

    group('DartFirebaseFunctionsException', () {
      test('is thrown for an HttpsError', () async {
        await expectLater(
          callable.call({}),
          throwsA(
            isA<DartFirebaseFunctionsException>()
                .having((e) => e.code, 'code', 'invalid-argument')
                .having((e) => e.message, 'message', 'Invalid test requested.'),
          ),
        );
      });

      test('carries the error details', () async {
        await expectLater(
          callable.call({
            'type': 'deepMap',
            'inputData': data.deepMap,
            'asError': true,
          }),
          throwsA(
            isA<DartFirebaseFunctionsException>()
                .having((e) => e.code, 'code', 'cancelled')
                .having((e) => e.details, 'details', data.deepMap),
          ),
        );
      });
    });

    test('instanceFor() accepts a custom region', () async {
      final europe = DartFirebaseFunctions.instanceFor(region: 'europe-west1');
      connectDartFunctionsEmulator(europe);
      final result =
          await europe.httpsCallable('testFunctionCustomRegion').call();
      expect(result.data, 'europe-west1');
    });

    test('times out when DartHttpsCallableOptions.timeout is exceeded',
        () async {
      final timeoutCallable = functions.httpsCallable(
        'testFunctionTimeout',
        options: const DartHttpsCallableOptions(timeout: Duration(seconds: 3)),
      );
      await expectLater(
        timeoutCallable.call({
          'testTimeout': const Duration(seconds: 6).inMilliseconds.toString(),
        }),
        throwsA(
          isA<DartFirebaseFunctionsException>()
              .having((e) => e.code, 'code', 'deadline-exceeded'),
        ),
      );
    });

    group(
      'Auth token',
      () {
        tearDown(() async {
          await FirebaseAuth.instance.signOut();
        });

        test('reaches the function when signed in', () async {
          final credential = await FirebaseAuth.instance.signInAnonymously();

          final result =
              await functions.httpsCallable('testEchoContext').call();

          expect(result.data['authUid'], credential.user!.uid);
          expect(result.data['authorizationHeader'], isTrue);
        });

        test('is not sent when signed out', () async {
          final result =
              await functions.httpsCallable('testEchoContext').call();

          expect(result.data['authUid'], isNull);
          expect(result.data['authorizationHeader'], isFalse);
        });
      },
      skip: !canUseAuth,
    );
  });
}

String get _listFruits2ndGenUrl =>
    'http://$emulatorUrlHost:5001/flutterfire-e2e-tests/us-central1/listfruits2ndgen';

String get _testFunctionDefaultRegionUrl =>
    'http://$emulatorUrlHost:5001/flutterfire-e2e-tests/us-central1/testFunctionDefaultRegion';
