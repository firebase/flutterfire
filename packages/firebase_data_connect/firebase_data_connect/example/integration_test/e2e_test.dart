// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:firebase_data_connect_example/firebase_options.dart';
import 'package:firebase_data_connect_example/generated/movies.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'generation_e2e.dart';
import 'instance_e2e.dart';
import 'listen_e2e.dart';
import 'query_e2e.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('firebase_data_connect', () {
    setUpAll(() async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final connector = MoviesConnector.connectorConfig;

      FirebaseDataConnect.instanceFor(connectorConfig: connector)
          .useDataConnectEmulator('localhost', 9399);
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: 'test@mail.com', password: 'password');
    });

    runInstanceTests();
    runQueryTests();
    runGenerationTest();
    runListenTests();
  });
}
