// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;

void main() {
  group('injectSrcScript', () {
    test('fails instead of hanging when the script cannot be loaded', () async {
      final coreWeb = FirebaseCoreWeb();
      final src = '${web.window.location.origin}/does-not-exist.js';

      await expectLater(
        coreWeb
            .injectSrcScript(src, 'firebase_missing')
            .timeout(const Duration(seconds: 10)),
        throwsA(
          isA<FirebaseException>()
              .having((e) => e.plugin, 'plugin', 'core')
              .having((e) => e.code, 'code', 'script-load-failed'),
        ),
      );

      expect(globalContext.has('firebase_missing'), isFalse);
      expect(globalContext.has('ff_trigger_firebase_missing'), isFalse);
    });
  });
}
