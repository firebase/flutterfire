// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock.dart';
import 'sample.dart' as data;

void main() {
  HttpsCallable? httpsCallable;

  setUp(() async {
    resetFirebaseCoreMocks();
    await Firebase.initializeApp();
    FirebaseFunctionsPlatform.instance =
        MockFirebaseFunctionsPlatform(region: 'us-central1');
    httpsCallable = FirebaseFunctions.instance.httpsCallable('foo');
  });

  group('HttpsCallable', () {
    group('call()', () {
      test('parameter validation accepts null values', () async {
        expect((await httpsCallable!.call(null)).data, isNull);
      });

      test('parameter validation accepts string values', () async {
        final result = await httpsCallable!.call('foo');
        expect(
          result.data,
          allOf(
            isA<String>(),
            equals('foo'),
          ),
        );
      });

      test('parameter validation accepts numeric values', () async {
        final result = await httpsCallable!.call(123);
        expect(result.data, equals(123));
      });

      test('parameter validation accepts boolean values', () async {
        final trueResult = await httpsCallable!.call(true);
        final falseResult = await httpsCallable!.call(false);
        expect(trueResult.data, isTrue);
        expect(falseResult.data, isFalse);
      });

      test('parameter validation accepts List values', () async {
        final result = await httpsCallable!.call(data.list);
        expect(
          result.data,
          allOf(
            isA<List>(),
            equals(data.list),
          ),
        );
      });

      test('parameter validation accepts nested List values', () async {
        final result = await httpsCallable!.call(data.deepList);
        expect(
          result.data,
          allOf(
            isA<List>(),
            equals(data.deepList),
          ),
        );
      });

      test('parameter validation accepts Map values', () async {
        final result = await httpsCallable!.call(data.map);
        expect(
          result.data,
          allOf(
            isA<Map>(),
            equals(data.map),
          ),
        );
      });

      test('parameter validation accepts nested Map values', () async {
        final result = await httpsCallable!.call(data.deepMap);
        expect(
          result.data,
          allOf(
            isA<Map>(),
            equals(data.deepMap),
          ),
        );
      });

      test('parameter validation throws if any other type of data is passed',
          () async {
        expect(() {
          return httpsCallable!.call(() => {});
        }, throwsA(isA<AssertionError>()));

        // Check nested values in Lists or Maps also throw if invalid:
        expect(() {
          return httpsCallable!.call({
            'valid': 'hello world',
            'not_valid': () => {},
          });
        }, throwsA(isA<AssertionError>()));
        expect(() {
          return httpsCallable!.call(['valid', () => {}]);
        }, throwsA(isA<AssertionError>()));
      });
    });
  });
}
