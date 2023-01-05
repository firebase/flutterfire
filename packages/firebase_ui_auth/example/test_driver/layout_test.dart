// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:drive/drive.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';

void main() {
  group(
    'Reauthenticate dialog',
    () {
      testWidgets("doesn't have an overflow when keyboard is visible",
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReauthenticateDialog(
                providers: [
                  EmailAuthProvider(),
                  PhoneAuthProvider(),
                  GoogleProvider(clientId: 'mock'),
                  AppleProvider(),
                ],
                auth: MockAuth(),
              ),
            ),
          ),
        );

        // Triggers keyboard to appear
        await tester.tap(find.byType(TextFormField).first);

        // Waits for keyboard to appear
        await tester.pumpAndSettle();

        // No need for an expect.
        // Test will fail if there is an overflow.
        // This is a built-in flutter functionality
      });
    },
  );
}

class MockUser extends Mock implements User {
  @override
  List<UserInfo> get providerData => [
        UserInfo({'providerId': 'password'}),
        UserInfo({'providerId': 'google.com'}),
        UserInfo({'providerId': 'apple.com'}),
        UserInfo({'providerId': 'phone'})
      ];
}

class MockAuth extends Mock implements FirebaseAuth {
  @override
  User? get currentUser => MockUser();
}
