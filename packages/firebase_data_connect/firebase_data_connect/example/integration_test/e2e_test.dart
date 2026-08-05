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

import 'cache_e2e.dart';
import 'generation_e2e.dart';
import 'instance_e2e.dart';
import 'listen_e2e.dart';
import 'query_e2e.dart';
import 'report_test_results.dart';
import 'websocket_e2e.dart';

Future<void> _signInTestUser() async {
  final auth = FirebaseAuth.instance;
  const password = 'password';
  final email = 'fdc-test-${DateTime.now().microsecondsSinceEpoch}@mail.com';

  for (var attempt = 0; attempt < 5; attempt++) {
    try {
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return;
      }

      if (attempt == 4) {
        rethrow;
      }
    }

    await Future<void>.delayed(Duration(seconds: attempt + 1));
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  reportTestResultsToDriver(binding);

  group('firebase_data_connect', () {
    setUpAll(() async {
      // The native SDK may already have configured [DEFAULT] from a bundled      // GoogleService-Info.plist (the plugin registrant does this before any      // Dart runs). Dart's Firebase.apps cannot see that app until the first      // platform-channel call, so the only reliable guard is catching the      // duplicate-app error and keeping the natively configured instance.      try {        await Firebase.initializeApp(          options: DefaultFirebaseOptions.currentPlatform,        );      } on FirebaseException catch (e) {        if (e.code != 'duplicate-app') {          rethrow;        }      }

      final connector = MoviesConnector.connectorConfig;

      FirebaseDataConnect.instanceFor(connectorConfig: connector)
          .useDataConnectEmulator('127.0.0.1', 9399);
      await FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);

      await _signInTestUser();
    });

    runInstanceTests();
    runQueryTests();
    runGenerationTest();
    runListenTests();
    runWebSocketTests();
    runCacheTests();
  });
}
