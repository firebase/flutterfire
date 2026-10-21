// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
@TestOn('chrome')
library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config_web/src/internals.dart';
import 'package:flutter_test/flutter_test.dart';

/// An error shaped like the ones the JS SDK reports through `onConfigUpdate`.
JSObject firebaseError(String code, String message) {
  final error = (globalContext['Error']! as JSFunction)
      .callAsConstructor<JSObject>('Remote Config: $message ($code).'.toJS);
  error['name'] = 'FirebaseError'.toJS;
  error['code'] = code.toJS;
  return error;
}

void main() {
  group('convertWebExceptions', () {
    test('reports realtime errors with the codes Android and iOS use',
        () async {
      const Map<String, String> codes = <String, String>{
        'remoteconfig/stream-error': 'config-update-stream-error',
        'remoteconfig/update-message-invalid': 'config-update-message-invalid',
        'remoteconfig/update-not-fetched': 'config-update-not-fetched',
        'remoteconfig/realtime-unavailable': 'config-update-unavailable',
      };
      final controller = StreamController<String>.broadcast(sync: true);
      final stream = convertWebExceptions(() => controller.stream);

      final expectation = expectLater(
        stream,
        emitsInOrder(<Object>[
          for (final MapEntry(key: jsCode, value: code) in codes.entries)
            emitsError(
              isA<FirebaseException>()
                  .having((e) => e.plugin, 'plugin', 'firebase_remote_config')
                  .having((e) => e.code, 'code', code)
                  .having(
                    (e) => e.message,
                    'message',
                    allOf(
                        contains('Unable to connect'), isNot(contains(jsCode))),
                  ),
            ),
          // The stream stays open after an error.
          'update',
        ]),
      );
      for (final String jsCode in codes.keys) {
        controller.addError(firebaseError(jsCode, 'Unable to connect'));
      }
      controller.add('update');

      await expectation;
      await controller.close();
    });
  });
}
