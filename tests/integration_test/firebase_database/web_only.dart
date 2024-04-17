// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firebase_database_web/firebase_database_web.dart';

void setupWebOnlyTests() {
  group(
    'web',
    () {
      test('convertFirebaseDatabaseException', () {
        Object jsErr(String? message) {
          return {
            'message': message,
          }.jsify()! as Object;
        }

        final cases = [
          ['Capital small', 'unknown'],
          [null, 'unknown'],
          ['Index not defined', 'index-not-defined'],
        ];

        for (var i = 0; i < cases.length; i++) {
          final message = cases[i][0];
          final convertedCode = cases[i][1];
          var converted = convertFirebaseDatabaseException(jsErr(message));

          expect(
            converted.message,
            message ?? '',
            reason: '[$i] Failed message check',
          );
          expect(
            converted.code,
            convertedCode,
            reason: '[$i] Failed code check',
          );
          expect(
            converted.plugin,
            'firebase_database',
            reason: '[$i] Failed plugin check',
          );
        }
      });
    },
    skip: !kIsWeb,
  );
}
