// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_platform_interface/src/action_code_settings.dart';
import 'package:firebase_auth_platform_interface/src/user_info.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class UserPlatform extends PlatformInterface {
  UserPlatform(this.auth, Map<String, dynamic> user)
      : _user = user,
        super(token: _token);

  static final Object _token = Object();

  static verifyExtends(UserPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
  }

  final FirebaseAuthPlatform auth;

  Map<String, dynamic> _user;

  String get displayName {
    return _user['displayName'];
  }

  String get email {
    return _user['email'];
  }

  bool get emailVerified {
    return _user['emailVerified'];
  }

  bool get isAnonymous {
    return _user['isAnonymous'];
  }

  UserMetadata get metadata {
    return UserMetadata(
        _user['metadata']['creationTime'], _user['metadata']['lastSignInTime']);
  }

  String get phoneNumber {
    return _user['phoneNumber'];
  }

  String get photoURL {
    return _user['photoURL'];
  }

  List<UserInfo> get providerData {
    return List.from(_user['providerData'])
        .map((data) => UserInfo(Map<String, dynamic>.from(data)))
        .toList();
  }

  String get refreshToken {
    return _user['refreshToken'];
  }

  String get tenantId {
    return _user['tenantId'];
  }

  String get uid {
    return _user['uid'];
  }

  Future<void> delete() async {
    throw UnimplementedError("delete() is not implemented");
  }

  Future<String> getIdToken(bool forceRefresh) {
    throw UnimplementedError("getIdToken() is not implemented");
  }

  Future<IdTokenResult> getIdTokenResult(bool forceRefresh) {
    throw UnimplementedError("getIdTokenResult() is not implemented");
  }

  Future<UserCredentialPlatform> linkWithCredential(AuthCredential credential) {
    throw UnimplementedError("linkWithCredential() is not implemented");
  }

  Future<UserCredentialPlatform> reauthenticateWithCredential(
      AuthCredential credential) {
    throw UnimplementedError(
        "reauthenticateWithCredential() is not implemented");
  }

  Future<void> reload() async {
    throw UnimplementedError("reload() is not implemented");
  }

  Future<void> sendEmailVerification(
      ActionCodeSettings actionCodeSettings) async {
    throw UnimplementedError("sendEmailVerification() is not implemented");
  }

  Future<UserPlatform> unlink(String providerId) async {
    throw UnimplementedError("unlink() is not implemented");
  }

  Future<void> updateEmail(String newEmail) async {
    throw UnimplementedError("updateEmail() is not implemented");
  }

  Future<void> updatePassword(String newPassword) async {
    throw UnimplementedError("updatePassword() is not implemented");
  }

  Future<void> updatePhoneNumber(PhoneAuthCredential phoneCredential) async {
    throw UnimplementedError("updatePhoneNumber() is not implemented");
  }

  Future<void> updateProfile(Map<String, String> profile) async {
    throw UnimplementedError("updateProfile() is not implemented");
  }

  Future<void> verifyBeforeUpdateEmail(String newEmail,
      [ActionCodeSettings actionCodeSettings]) async {
    throw UnimplementedError("verifyBeforeUpdateEmail() is not implemented");
  }
}
