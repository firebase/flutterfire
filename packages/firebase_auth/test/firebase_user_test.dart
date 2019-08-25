// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

final String testDisplayName = 'testDisplayName';
final String testToken = 'testToken';

class TestFirebaseUser implements FirebaseUser {
  String _username;
  String _password;
  String _email;
  String _displayName = testDisplayName;
  String _token = testToken;
  String _uid;

  @override
  Future<void> delete() {
    return null;
  }

  @override
  String get displayName => _displayName;

  @override
  String get email => _email;

  @override
  Future<IdTokenResult> getIdToken({bool refresh = false}) async {
    return IdTokenResult.fromToken(_token);
  }

  @override
  bool get isAnonymous => false;

  @override
  bool get isEmailVerified => true;

  @override
  Future<AuthResult> linkWithCredential(AuthCredential credential) async {
    return AuthResult.fromUser(this);
  }

  @override
  FirebaseUserMetadata get metadata => null;

  @override
  String get phoneNumber => 'None';

  @override
  String get photoUrl => 'None';

  @override
  List<UserInfo> get providerData => <UserInfo>[];

  @override
  String get providerId => 'None';

  @override
  Future<AuthResult> reauthenticateWithCredential(
      AuthCredential credential) async {
    return AuthResult.fromUser(this);
  }

  @override
  Future<void> reload() async => null;

  @override
  Future<void> sendEmailVerification() async => null;

  @override
  String get uid => _uid;

  @override
  Future<void> unlinkFromProvider(String provider) async => null;

  @override
  Future<void> updateEmail(String email) async {
    _email = email;
    return null;
  }

  @override
  Future<void> updatePassword(String password) async {
    _password = password;
    return null;
  }

  @override
  Future<void> updatePhoneNumberCredential(AuthCredential credential) async =>
      null;

  @override
  Future<void> updateProfile(UserUpdateInfo userUpdateInfo) async {
    _displayName = userUpdateInfo.displayName;
    return null;
  }
}

void main() {
  test('Expect TestFirebaseUser can be constructed and used.', () async {
    final FirebaseUser testUser = TestFirebaseUser();
    expect(testUser.displayName, testDisplayName);
    expect(testUser.isAnonymous, false);
    expect((await testUser.getIdToken()).token, testToken);
    expect((await testUser.linkWithCredential(null)).user, testUser);
  });
}
