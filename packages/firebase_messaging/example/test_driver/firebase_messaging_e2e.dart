// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:e2e/e2e.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  group('$FirebaseMessaging', () {
    FirebaseMessaging firebaseMessaging;
    setUp(() async {
      await Firebase.initializeApp();
      firebaseMessaging = await FirebaseMessaging();
    });

    testWidgets('autoInitEnabled', (WidgetTester tester) async {
      await firebaseMessaging.setAutoInitEnabled(false);
      expect(await firebaseMessaging.autoInitEnabled(), false);
      await firebaseMessaging.setAutoInitEnabled(true);
      expect(await firebaseMessaging.autoInitEnabled(), true);
    });

    // TODO(jackson): token retrieval isn't working on test devices yet
    testWidgets('subscribeToTopic', (WidgetTester tester) async {
      await firebaseMessaging.subscribeToTopic('foo');
    }, skip: true);

    // TODO(jackson): token retrieval isn't working on test devices yet
    testWidgets('unsubscribeFromTopic', (WidgetTester tester) async {
      await firebaseMessaging.unsubscribeFromTopic('foo');
    }, skip: true);

    testWidgets('deleteInstanceID', (WidgetTester tester) async {
      final bool result = await firebaseMessaging.deleteInstanceID();
      expect(result, isTrue);
    });
  });
}
