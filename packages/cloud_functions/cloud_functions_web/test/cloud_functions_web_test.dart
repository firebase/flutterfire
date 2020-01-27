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

void _debugLog(String message) {
  print('DBL TEST: $message');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$CloudFunctionsWeb', () {
    final List<Map<String, dynamic>> log = <Map<String, dynamic>>[];

    Map<String, dynamic> loggingCall(
        {@required String appName,
        @required String functionName,
        dynamic parameters}) {
      log.add(<String, dynamic>{
        'appName': appName,
        'functionName': functionName,
        'parameters': parameters
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
        ),
      ));

      FirebaseCorePlatform.instance = FirebaseCoreWeb();
      CloudFunctionsPlatform.instance = CloudFunctionsWeb();

      log.clear();
    });

    test('callCloudFunction calls down to Firebase API', () async {
      // install loggingCall on the HttpsCallable mock as the thing that gets
      // executed when its call method is invoked
      firebaseMock.functions = allowInterop(([app]) => FirebaseFunctionsMock(
            httpsCallable: allowInterop(
              (functionName, [options]) {
                _debugLog('FirebaseFunctionsMock getting a callable for app ${app.name} with function name $functionName');
                return FirebaseHttpsCallableMock(
                    call: allowInterop(([data]) {
                      _debugLog('FirebaseHttpsCallableMock \'$functionName\' is being called');
                      log.add(<String, dynamic>{
                        'appName': app.name,
                        'functionName': functionName,
                        'parameters': data
                      });
                      return Future(() => FirebaseHttpsCallableResultMock(data: allowInterop((_) => <String, dynamic>{
                                              'foo': 'bar',
                                            })));
                    }
                    ),
                );
              },
            ),
            useFunctionsEmulator: allowInterop((url) {
              _debugLog('Unimplemented. Supposed to emulate at $url');
            }),
          ));
      firebase.App app = firebase.app('mock');
      expect(app.options.appId, equals('123'));
      _debugLog('Installed ${firebaseMock.functions} on firebaseMock');
      firebase.Functions fs = firebase.functions(app);
      _debugLog('Fetched functions as $fs');
      firebase.HttpsCallable callable = fs.httpsCallable('foobie');
      _debugLog('callable is $callable');
      await callable.call();
      expect(log, <Matcher>[
        equals(<String, dynamic>{
          'appName': '[DEFAULT]',
          'functionName': 'foobie',
          'parameters': null,
        }),
      ]);

      log.clear();
      _debugLog('calling directly at mock worked');

      CloudFunctionsPlatform cfp = CloudFunctionsPlatform.instance;
      expect(cfp, isA<CloudFunctionsWeb>());
      dynamic result = await cfp.callCloudFunction(
          appName: '[DEFAULT]', functionName: 'baz');

      expect(result, isNotNull);

      expect(
        log,
        <Matcher>[
          equals(<String, dynamic>{
            'appName': '[DEFAULT]',
            'functionName': 'baz',
            'parameters': null
          }),
        ],
      );
    });
  });
}
