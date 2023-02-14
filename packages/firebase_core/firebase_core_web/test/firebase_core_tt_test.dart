// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:flutter_test/flutter_test.dart';

import 'tools.dart';

// NOTE: This file needs to be separated from the others because Content
// Security Policies can never be *relaxed* once set.
//
// In order to not introduce a dependency in the order of the tests, we split
// them in different files, depending on the strictness of their CSP:
//
// * js_loader_test.dart : default TT configuration (not enforced)
// * js_loader_tt_custom_test.dart : TT are customized, but allowed
// * js_loader_tt_forbidden_test.dart: TT are completely disallowed

void main() {
  group('injectScript (TrustedTypes configured)', () {
    injectMetaTag(<String, String>{
      'http-equiv': 'Content-Security-Policy',
      'content': "trusted-types my-custom-policy-name 'allow-duplicates';",
    });

    test('Should inject Firebase Core script properly', () {
      final coreWeb = FirebaseCoreWeb();
      final version = coreWeb.firebaseSDKVersion;
      final Future<void> done = coreWeb.injectSrcScript(
        'https://www.gstatic.com/firebasejs/$version/firebase-app.js',
        'firebase_core',
      );

      expect(done, isA<Future<void>>());
    });
  });
}
