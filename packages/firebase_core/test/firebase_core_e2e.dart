// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e2e/e2e.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('configure', (WidgetTester tester) async {
    await FirebaseApp.configure(
      name: 'foo',
      options: const FirebaseOptions(
        googleAppID: '1:297855924061:ios:c6de2b69b03a5be8',
        gcmSenderID: '297855924061',
        apiKey: 'AIzaSyBq6mcufFXfyqr79uELCiqM_O_1-G72PVU',
      ),
    );

    final List<FirebaseApp> apps = await FirebaseApp.allApps();
    expect(apps, hasLength(1));

    final FirebaseOptions options = await apps[0].options;

    expect(options.apiKey, 'AIzaSyBq6mcufFXfyqr79uELCiqM_O_1-G72PVU');
    expect(options.gcmSenderID, '297855924061');
    expect(options.googleAppID, '1:297855924061:ios:c6de2b69b03a5be8');
  });
}
