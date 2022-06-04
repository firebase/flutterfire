// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'firestore_list_view_test.dart' as firestore_list_view;
import 'firestore_query_builder_test.dart' as firestore_query_builder;
import 'email_form_test.dart' as email_form;
import 'email_link_sign_in_view_test.dart' as email_link_sign_in_view;
import 'universal_email_sign_in_screen_test.dart'
    as universal_email_sign_in_screen;

import 'utils.dart';

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(prepare);

  tearDown(() async {
    final auth = FirebaseAuth.instance;
    final providers = await auth.fetchSignInMethodsForEmail('test@test.com');

    if (auth.currentUser != null) {
      return auth.currentUser!.delete();
    }

    if (providers.contains('password')) {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: 'test@test.com',
        password: 'password',
      );

      await auth.currentUser!.delete();
    }
  });

  firestore_query_builder.main();
  firestore_list_view.main();
  email_form.main();
  email_link_sign_in_view.main();
  universal_email_sign_in_screen.main();
}
