// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    globalContext.delete('flutterfire_ignore_scripts'.toJS);
  });

  test('reads service names from a JS array on window', () {
    // Matches `window.flutterfire_ignore_scripts = ['analytics'];` in index.html.
    globalContext.callMethod(
      'eval'.toJS,
      "window.flutterfire_ignore_scripts = ['analytics', 'firestore']".toJS,
    );

    expect(
      FirebaseCoreWeb().ignoredServiceScripts,
      ['analytics', 'firestore'],
    );
  });

  test('returns an empty list when the window property is missing', () {
    expect(FirebaseCoreWeb().ignoredServiceScripts, isEmpty);
  });

  test('returns an empty list when the window property is not an array', () {
    globalContext['flutterfire_ignore_scripts'] = 'analytics'.toJS;

    expect(FirebaseCoreWeb().ignoredServiceScripts, isEmpty);
  });
}
