// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_platform_interface/src/method_channel/utils/convert_auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('convertToOAuthProvider()', () {
    test('keeps YahooAuthProvider scopes and custom parameters', () {
      final provider = YahooAuthProvider()
        ..addScope('mail-r')
        ..setCustomParameters({'prompt': 'login'});

      final converted = convertToOAuthProvider(provider);

      expect(converted, isA<OAuthProvider>());
      converted as OAuthProvider;
      expect(converted.providerId, 'yahoo.com');
      expect(converted.scopes, ['mail-r']);
      expect(converted.parameters, {'prompt': 'login'});
    });
  });
}
