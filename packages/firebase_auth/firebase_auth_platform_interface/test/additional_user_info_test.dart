// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final bool kMockIsNewUser = true;
  final String kMockDisplayName = 'test-name';
  final Map<String, dynamic> kMockProfile = <String, dynamic>{
    'displayName': kMockDisplayName
  };
  final String kMockProviderId = 'password';
  final String kMockUsername = 'username';

  group('$AdditionalUserInfo', () {
    AdditionalUserInfo additionalUserInfo = AdditionalUserInfo(
        isNewUser: kMockIsNewUser,
        profile: kMockProfile,
        providerId: kMockProviderId,
        username: kMockUsername);
    group('Constructor', () {
      test('returns an instance of [AdditionalUserInfo]', () {
        expect(additionalUserInfo, isA<AdditionalUserInfo>());

        expect(additionalUserInfo.providerId, equals(kMockProviderId));
        expect(additionalUserInfo.isNewUser, equals(kMockIsNewUser));
        expect(additionalUserInfo.username, equals(kMockUsername));
        expect(additionalUserInfo.profile, equals(kMockProfile));
      });
    });

    group('toString', () {
      test('returns expected string', () {
        final result = additionalUserInfo.toString();
        expect(result, isA<String>());
        expect(
            result,
            equals(
                '$AdditionalUserInfo(isNewUser: $kMockIsNewUser, profile: ${kMockProfile.toString()}, providerId: $kMockProviderId, username: $kMockUsername)'));
      });

      test('returns expected string when profile is null', () {
        AdditionalUserInfo additionalUserInfo = AdditionalUserInfo(
            isNewUser: kMockIsNewUser,
            profile: null,
            providerId: kMockProviderId,
            username: kMockUsername);

        expect(
            additionalUserInfo.toString(),
            equals(
                '$AdditionalUserInfo(isNewUser: $kMockIsNewUser, profile: null, providerId: $kMockProviderId, username: $kMockUsername)'));
      });
    });
  });
}
