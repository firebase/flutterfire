// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
@TestOn('chrome')

import 'dart:js' show allowInterop;

import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';
import 'package:cloud_functions_web/cloud_functions_web.dart';
import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

import 'mock/firebase_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$FirebaseFunctionsWeb', () {
    final List<Map<String, dynamic>> log = <Map<String, dynamic>>[];

    Map<String, dynamic> loggingCall(
        {@required String appName,
        @required String functionName,
        String region,
        dynamic parameters}) {
      log.add(<String, dynamic>{
        'appName': appName,
        'functionName': functionName,
        'region': region
      });
      return <String, dynamic>{
        'foo': 'bar',
      };
    }

    setUp(() async {
      firebaseMock = FirebaseMock(
          app: allowInterop(
        (String name) => FirebaseAppMock(
            name: name,
            options: FirebaseAppOptionsMock(appId: '123'),
            functions: allowInterop(([region]) => FirebaseFunctionsMock(
                  httpsCallable: allowInterop((functionName, [options]) {
                    final String appName = name == null ? '[DEFAULT]' : name;
                    return allowInterop(([data]) {
                      Map<String, dynamic> result = loggingCall(
                          appName: appName,
                          functionName: functionName,
                          region: region);
                      return _jsPromise(FirebaseHttpsCallableResultMock(
                          data: allowInterop((_) => result)));
                    });
                  }),
                  useFunctionsEmulator: allowInterop((url) {
                    print('Unimplemented. Supposed to emulate at $url');
                  }),
                ))),
      ));

      FirebasePlatform.instance = FirebaseCoreWeb();
      FirebaseFunctionsPlatform.instance = FirebaseFunctionsWeb();

      // install loggingCall on the HttpsCallable mock as the thing that gets
      // executed when its call method is invoked
      firebaseMock.functions = allowInterop(([app]) => FirebaseFunctionsMock(
            httpsCallable: allowInterop((functionName, [options]) {
              final String appName = app == null ? '[DEFAULT]' : app.name;
              return allowInterop(([data]) {
                Map<String, dynamic> result =
                    loggingCall(appName: appName, functionName: functionName);
                return _jsPromise(FirebaseHttpsCallableResultMock(
                    data: allowInterop((_) => result)));
              });
            }),
            useFunctionsEmulator: allowInterop((url) {
              print('Unimplemented. Supposed to emulate at $url');
            }),
          ));
    });

    test('setUp wires up mock objects properly', () async {
      log.clear();

      firebase.App app = firebase.app('[DEFAULT]');
      expect(app.options.appId, equals('123'));
      firebase.Functions fs = firebase.functions(app);
      firebase.HttpsCallable callable = fs.httpsCallable('foobie');
      await callable.call();
      expect(log, <Matcher>[
        equals(<String, dynamic>{
          'appName': '[DEFAULT]',
          'functionName': 'foobie',
          'region': null
        }),
      ]);
    });
  });
}

Promise _jsPromise(dynamic value) {
  return Promise(allowInterop((void resolve(dynamic result), Function reject) {
    resolve(value);
  }));
}
