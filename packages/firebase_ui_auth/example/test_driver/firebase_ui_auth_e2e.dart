// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'email_form_test.dart' as email_form;
import 'email_link_sign_in_view_test.dart' as email_link_sign_in_view;
import 'universal_email_sign_in_screen_test.dart'
    as universal_email_sign_in_screen;
import 'phone_verification_test.dart' as phone_verification;
import 'google_sign_in_test.dart' as google_sign_in;
import 'twitter_sign_in_test.dart' as twitter_sign_in;
import 'apple_sign_in_test.dart' as apple_sign_in;
import 'facebook_sign_in_test.dart' as facebook_sign_in;
import 'layout_test.dart' as layout;

import 'utils.dart';

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(prepare);

  tearDown(() async {
    await FirebaseAuth.instance.signOut();
    await deleteAllAccounts();
  });

  email_form.main();
  email_link_sign_in_view.main();
  universal_email_sign_in_screen.main();

  if (isMobile) {
    phone_verification.main();
    google_sign_in.main();
    twitter_sign_in.main();
    facebook_sign_in.main();
    apple_sign_in.main();
  } else if (defaultTargetPlatform == TargetPlatform.macOS) {
    apple_sign_in.main();
  }

  layout.main();
}
