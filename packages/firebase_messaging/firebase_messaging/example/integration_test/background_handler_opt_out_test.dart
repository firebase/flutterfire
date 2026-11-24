// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging_example/firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'remote_notification_delivery.dart';
import 'report_test_results.dart';

/// Runs only when the example APK sets
/// `firebase_messaging_background_handler_enabled` to false. The default e2e
/// build leaves that entry out.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  reportTestResultsToDriver(binding);

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  test('a stored handler is cleared and the background service does not start '
      'when the manifest opt-out is set', () async {
    expect(
      await androidBackgroundHandlerEnabled(),
      isFalse,
      reason:
          'This file is for an APK whose manifest sets '
          'firebase_messaging_background_handler_enabled to false.',
    );

    final probe = await probeBackgroundDelivery(
      'opt-out-${DateTime.now().microsecondsSinceEpoch}',
      pluginHandle: 42,
      userHandle: 99,
    );

    expect(probe['background'], isTrue);
    expect(probe['receiverRan'], isTrue);
    expect(probe['serviceRan'], isFalse);
    expect(probe['jobScheduled'], isFalse);
    expect(probe['serviceRunning'], isFalse);
    expect(probe['pluginHandle'], 0);
    expect(probe['userHandle'], 0);
  }, skip: kIsWeb || defaultTargetPlatform != TargetPlatform.android);
}
