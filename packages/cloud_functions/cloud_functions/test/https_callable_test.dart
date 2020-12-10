// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock.dart';

import 'package:mockito/mockito.dart';
import 'sample.dart' as data;

void main() {
  setupFirebaseFunctionsMocks();
  FirebaseApp app;

  FirebaseFunctions functions;
  HttpsCallable kHttpsCallable;

  group('$HttpsCallable', () {
    setUpAll(() async {
      app = await Firebase.initializeApp();
      kMockFirebaseFunctionsPlatform = MockFirebaseFunctionsPlatform(app, '');
      FirebaseFunctionsPlatform.instance = kMockFirebaseFunctionsPlatform;
      functions = FirebaseFunctions.instance;

      when(kMockFirebaseFunctionsPlatform.httpsCallable(any, any, any))
          .thenAnswer((_) {
        return kMockHttpsCallablePlatform;
      });

      when(kMockFirebaseFunctionsPlatform.delegateFor(
              app: anyNamed('app'), region: anyNamed('region')))
          .thenAnswer((_) {
        return kMockFirebaseFunctionsPlatform;
      });

      when(kMockHttpsCallablePlatform(any)).thenAnswer((_) {
        return Future.value(kMockHttpsCallablePlatform);
      });

      kHttpsCallable = functions.httpsCallable('test_name',
          options: HttpsCallableOptions(timeout: Duration(minutes: 1)));
    });

    group('constructor', () {
      test('returns an instance of [HttpsCallable]', () {
        expect(kHttpsCallable, isA<HttpsCallable>());
      });
    });

    group('call()', () {
      test('returns an instance of [HttpsCallableResult]', () async {
        expect(await kHttpsCallable(), isA<HttpsCallableResult>());
        verify(kMockHttpsCallablePlatform.call());
      });

      test('accepts null', () async {
        expect(await kHttpsCallable(null), isA<HttpsCallableResult>());
        verify(kMockHttpsCallablePlatform.call(null));
      });

      test('accepts String', () async {
        expect(await kHttpsCallable.call('foo'), isA<HttpsCallableResult>());
        verify(kMockHttpsCallablePlatform.call('foo'));
      });

      test('accepts [num]', () async {
        expect(await kHttpsCallable(123), isA<HttpsCallableResult>());
        verify(kMockHttpsCallablePlatform.call(123));
      });

      test('accepts [bool]', () async {
        expect(await kHttpsCallable(true), isA<HttpsCallableResult>());
        verify(kMockHttpsCallablePlatform.call(true));
        expect(await kHttpsCallable(false), isA<HttpsCallableResult>());
        verify(kMockHttpsCallablePlatform.call(false));
      });

      test('accepts a [List]', () async {
        await kHttpsCallable(data.list);
        verify(kMockHttpsCallablePlatform.call(data.list));
      });

      test('accepts a deeply nested [Map]', () async {
        dynamic parameters = {
          'type': 'deepMap',
          'inputData': data.deepMap,
        };
        await kHttpsCallable(parameters);
        verify(kMockHttpsCallablePlatform(parameters));
      });

      test('accepts a deeply nested [List]', () async {
        dynamic parameters = {
          'type': 'deepMap',
          'inputData': data.deepList,
        };
        await kHttpsCallable(parameters);
        verify(kMockHttpsCallablePlatform(parameters));
      });
    });

    group('set.timeout (deprecated)', () {
      test('sets timeout value', () async {
        // ignore: deprecated_member_use_from_same_package
        kHttpsCallable.timeout = Duration(minutes: 2);

        verify(kMockHttpsCallablePlatform.timeout = Duration(minutes: 2));
      });
    });
  });
}
