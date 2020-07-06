// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_auth;

class User {
  UserPlatform _delegate;

  final FirebaseAuth _auth;

  User._(this._auth, this._delegate) {
    UserPlatform.verifyExtends(_delegate);
  }

  String get displayName {
    return _delegate.displayName;
  }

  String get email {
    return _delegate.email;
  }

  bool get emailVerified {
    return _delegate.emailVerified;
  }

  bool get isAnonymous {
    return _delegate.isAnonymous;
  }

  UserMetadata get metadata {
    return _delegate.metadata;
  }

  String get phoneNumber {
    return _delegate.phoneNumber;
  }

  String get photoURL {
    return _delegate.photoURL;
  }

  List<UserInfo> get providerData {
    return _delegate.providerData;
  }

  String get refreshToken {
    return _delegate.refreshToken;
  }

  String get tenantId {
    return _delegate.tenantId;
  }

  String get uid {
    return _delegate.uid;
  }

  Future<void> delete() {
    return _delegate.delete();
  }

  Future<String> getIdToken([bool forceRefresh = false]) {
    return _delegate.getIdToken(forceRefresh);
  }

  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) {
    return _delegate.getIdTokenResult(forceRefresh);
  }

  Future<UserCredential> linkWithCredential(AuthCredential credential) async {
    assert(credential != null);
    return UserCredential._(
        _auth, await _delegate.linkWithCredential(credential));
  }

  // TODO linkWithPhoneNumber

  Future<UserCredential> reauthenticateWithCredential(
      AuthCredential credential) async {
    assert(credential != null);
    return UserCredential._(
        _auth, await _delegate.reauthenticateWithCredential(credential));
  }

  // reauthenticateWithPhoneNumber

  Future<void> reload() async {
    await _delegate.reload();
  }

  Future<void> sendEmailVerification(
      [ActionCodeSettings actionCodeSettings]) async {
    await _delegate.sendEmailVerification(actionCodeSettings);
  }

  Future<User> unlink(String providerId) async {
    assert(providerId != null);
    return User._(_auth, await _delegate.unlink(providerId));
  }

  Future<void> updateEmail(String newEmail) async {
    assert(newEmail != null);
    await _delegate.updateEmail(newEmail);
  }

  Future<void> updatePassword(String newPassword) async {
    assert(newPassword != null);
    await _delegate.updatePassword(newPassword);
  }

  Future<void> updatePhoneNumber(PhoneAuthCredential phoneCredential) async {
    assert(phoneCredential != null);
    await _delegate.updatePhoneNumber(phoneCredential);
  }

  Future<void> updateProfile({String displayName, String photoURL}) async {
    await _delegate.updateProfile(<String, String>{
      'displayName': displayName,
      'photoURL': photoURL,
    });
  }

  Future<void> verifyBeforeUpdateEmail(String newEmail,
      [ActionCodeSettings actionCodeSettings]) async {
    assert(newEmail != null);
    await _delegate.verifyBeforeUpdateEmail(newEmail, actionCodeSettings);
  }

  @override
  String toString() {
    return '$User(displayName: $displayName, email: $email, emailVerified: $emailVerified, isAnonymous: $isAnonymous, metadata: ${metadata.toString()}, phoneNumber: $phoneNumber, photoURL: $photoURL, providerData, ${providerData.toString()}, refreshToken: $refreshToken, tenantId: $tenantId, uid: $uid)';
  }
}
