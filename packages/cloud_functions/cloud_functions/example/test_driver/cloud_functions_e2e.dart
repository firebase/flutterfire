// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:e2e/e2e.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_functions/cloud_functions.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('call', (WidgetTester tester) async {
    final HttpsCallable callable =
        CloudFunctions.instance.getHttpsCallable(functionName: 'repeat');
    final HttpsCallableResult response = await callable.call(<String, dynamic>{
      'message': 'foo',
      'count': 1,
    });
    expect(response.data['repeat_message'], 'foo');
  });
}
