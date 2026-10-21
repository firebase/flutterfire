// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_web/cloud_firestore_web.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    // Minimal stand-in for the Firestore JS SDK, which unit tests do not load.
    final firestoreSdk = JSObject();
    firestoreSdk['memoryLocalCache'] = ((JSAny? settings) => JSObject()).toJS;
    globalContext['firebase_firestore'] = firestoreSdk;
  });

  test('settings keeps the long polling fields', () {
    final firestore = FirebaseFirestoreWeb();
    const longPollingOptions = WebExperimentalLongPollingOptions(
      timeoutDuration: Duration(seconds: 10),
    );

    firestore.settings = const Settings(
      webExperimentalForceLongPolling: true,
      webExperimentalAutoDetectLongPolling: false,
      webExperimentalLongPollingOptions: longPollingOptions,
    );

    expect(firestore.settings.webExperimentalForceLongPolling, isTrue);
    expect(firestore.settings.webExperimentalAutoDetectLongPolling, isFalse);
    expect(
      firestore.settings.webExperimentalLongPollingOptions,
      longPollingOptions,
    );
  });
}
